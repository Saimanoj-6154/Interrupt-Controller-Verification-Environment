module claim_legality_assertions #(
    parameter int N_SRC = 16,
    parameter int ID_W = $clog2(N_SRC + 1)
) (
    input logic clk_i,
    input logic rst_ni,
    input logic claim_read_i,
    input logic [ID_W-1:0] claim_id_i
);

    property legal_claim;
        @(posedge clk_i)
        disable iff (!rst_ni)
        claim_read_i |-> claim_id_i <= N_SRC;
    endproperty

    assert property (legal_claim)
        else $error("Claim returned an illegal interrupt ID");

endmodule
