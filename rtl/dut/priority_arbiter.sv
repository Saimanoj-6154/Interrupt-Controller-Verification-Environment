module priority_arbiter #(
    parameter int N_SRC  = 16,
    parameter int PRIO_W = 3,
    parameter int ID_W   = $clog2(N_SRC + 1)
) (
    input  logic [N_SRC-1:0]             pending_i,
    input  logic [N_SRC-1:0]             enable_i,
    input  logic [N_SRC-1:0][PRIO_W-1:0] priority_i,
    input  logic [PRIO_W-1:0]            threshold_i,

    output logic                         valid_o,
    output logic [ID_W-1:0]              id_o,
    output logic [PRIO_W-1:0]             priority_o
);

    always_comb begin
        valid_o    = 1'b0;
        id_o       = '0;
        priority_o = '0;

        // Highest priority wins.
        // Equal priority: lowest source index wins.
        for (int i = 0; i < N_SRC; i++) begin
            if (pending_i[i] &&
                enable_i[i] &&
                priority_i[i] != 0 &&
                priority_i[i] > threshold_i) begin

                if (!valid_o || priority_i[i] > priority_o) begin
                    valid_o    = 1'b1;
                    id_o       = ID_W'(i + 1);
                    priority_o = priority_i[i];
                end
            end
        end
    end

endmodule
