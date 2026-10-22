module no_double_claim_assertions #(
    parameter int N_SRC = 16,
    parameter int ID_W = $clog2(N_SRC + 1)
) (
    input logic clk_i,
    input logic rst_ni,

    input logic claim_valid_i,
    input logic [ID_W-1:0] claim_id_i,

    input logic complete_valid_i,
    input logic [ID_W-1:0] complete_id_i
);

    logic [N_SRC:1] claimed_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            claimed_q <= '0;
        end else begin

            if (complete_valid_i &&
                complete_id_i inside {[1:N_SRC]]) begin
                claimed_q[complete_id_i] <= 1'b0;
            end

            if (claim_valid_i &&
                claim_id_i inside {[1:N_SRC]]) begin
                claimed_q[claim_id_i] <= 1'b1;
            end
        end
    end

    property no_repeated_claim;
        @(posedge clk_i)
        disable iff (!rst_ni)
        claim_valid_i &&
        claim_id_i inside {[1:N_SRC]}
        |-> !claimed_q[claim_id_i];
    endproperty

    assert property (no_repeated_claim)
        else $error("Interrupt claimed twice before completion");

endmodule
