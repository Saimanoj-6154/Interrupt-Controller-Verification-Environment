module irq_controller #(
    parameter int N_SRC  = 16,
    parameter int N_TGT  = 2,
    parameter int PRIO_W = 3,
    parameter int ID_W   = $clog2(N_SRC + 1),
    parameter int TGT_W  = (N_TGT < 2) ? 1 : $clog2(N_TGT)
) (
    input  logic                  clk_i,
    input  logic                  rst_ni,

    input  logic [N_SRC-1:0]      intr_i,

    input  logic                  reg_valid_i,
    input  logic                  reg_write_i,
    input  logic [TGT_W-1:0]      reg_target_i,
    input  logic [15:0]           reg_addr_i,
    input  logic [31:0]           reg_wdata_i,

    output logic                  reg_ready_o,
    output logic [31:0]           reg_rdata_o,
    output logic [N_TGT-1:0]      irq_o
);

    logic [PRIO_W-1:0] priority_q [N_SRC];

    logic [N_SRC-1:0] pending_q;
    logic [N_SRC-1:0] prev_intr_q;

    logic [N_SRC-1:0] enable_q [N_TGT];
    logic [PRIO_W-1:0] threshold_q [N_TGT];

    logic [N_SRC-1:0][PRIO_W-1:0] pri_vec;

    logic valid [N_TGT];
    logic [ID_W-1:0] claim_id [N_TGT];
    logic [PRIO_W-1:0] claim_prio [N_TGT];

    // Pack priority array for the arbitration modules.
    for (genvar p = 0; p < N_SRC; p++) begin : GEN_PRI
        assign pri_vec[p] = priority_q[p];
    end

    // One arbiter per target.
    for (genvar t = 0; t < N_TGT; t++) begin : GEN_ARB

        priority_arbiter #(
            .N_SRC  (N_SRC),
            .PRIO_W (PRIO_W),
            .ID_W   (ID_W)
        ) u_arbiter (
            .pending_i   (pending_q),
            .enable_i    (enable_q[t]),
            .priority_i  (pri_vec),
            .threshold_i (threshold_q[t]),
            .valid_o     (valid[t]),
            .id_o        (claim_id[t]),
            .priority_o  (claim_prio[t])
        );

        assign irq_o[t] = valid[t];

    end

    // Simplified register read interface.
    always_comb begin
        reg_ready_o = reg_valid_i;
        reg_rdata_o = '0;

        if (reg_valid_i && !reg_write_i) begin

            // Source priorities: 0x0000 + 4*source_index
            if ((reg_addr_i < 16'h0100) &&
                (reg_addr_i[1:0] == 2'b00) &&
                ((reg_addr_i / 4) < N_SRC)) begin

                reg_rdata_o = priority_q[reg_addr_i / 4];

            end

            // Pending bitmap
            else if (reg_addr_i == 16'h1000) begin
                reg_rdata_o = pending_q;
            end

            // Enable bitmap for selected target
            else if (reg_addr_i == 16'h2000) begin
                reg_rdata_o = enable_q[reg_target_i];
            end

            // Threshold for selected target
            else if (reg_addr_i == 16'h3000) begin
                reg_rdata_o = threshold_q[reg_target_i];
            end

            // Claim: return highest eligible source ID
            else if (reg_addr_i == 16'h3004) begin
                reg_rdata_o =
                    valid[reg_target_i]
                    ? claim_id[reg_target_i]
                    : '0;
            end
        end
    end

    // Sequential state and register writes.
    always_ff @(posedge clk_i or negedge rst_ni) begin

        if (!rst_ni) begin

            pending_q  <= '0;
            prev_intr_q <= '0;

            for (int i = 0; i < N_SRC; i++) begin
                priority_q[i] <= '0;
            end

            for (int t = 0; t < N_TGT; t++) begin
                enable_q[t]    <= '0;
                threshold_q[t] <= '0;
            end

        end else begin

            prev_intr_q <= intr_i;

            // Capture rising edges from interrupt sources.
            pending_q <= pending_q |
                         (intr_i & ~prev_intr_q);

            if (reg_valid_i && reg_write_i) begin

                if ((reg_addr_i < 16'h0100) &&
                    (reg_addr_i[1:0] == 2'b00) &&
                    ((reg_addr_i / 4) < N_SRC)) begin

                    priority_q[reg_addr_i / 4]
                        <= reg_wdata_i[PRIO_W-1:0];

                end

                else if (reg_addr_i == 16'h2000) begin
                    enable_q[reg_target_i]
                        <= reg_wdata_i[N_SRC-1:0];
                end

                else if (reg_addr_i == 16'h3000) begin
                    threshold_q[reg_target_i]
                        <= reg_wdata_i[PRIO_W-1:0];
                end

                // Simplified completion operation.
                else if ((reg_addr_i == 16'h3004) &&
                         (reg_wdata_i[ID_W-1:0] > 0) &&
                         (reg_wdata_i[ID_W-1:0] <= N_SRC)) begin

                    pending_q[reg_wdata_i[ID_W-1:0]-1]
                        <= 1'b0;
                end
            end

            // Claim read clears the selected pending bit.
            if (reg_valid_i &&
                !reg_write_i &&
                reg_addr_i == 16'h3004 &&
                valid[reg_target_i]) begin

                pending_q[claim_id[reg_target_i]-1] <= 1'b0;

            end

        end
    end

endmodule
