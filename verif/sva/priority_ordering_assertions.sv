module priority_ordering_assertions #(
    parameter int N_SRC = 16,
    parameter int PRIO_W = 3,
    parameter int ID_W = $clog2(N_SRC + 1)
) (
    input logic clk_i,
    input logic rst_ni,

    input logic claim_valid_i,
    input logic [ID_W-1:0] claim_id_i,

    input logic [N_SRC-1:0] eligible_i,
    input logic [N_SRC-1:0][PRIO_W-1:0] priority_i
);

    always_ff @(posedge clk_i) begin
        if (rst_ni &&
            claim_valid_i &&
            claim_id_i inside {[1:N_SRC]]) begin

            for (int i = 0; i < N_SRC; i++) begin
                if (eligible_i[i] &&
                    priority_i[i] >
                    priority_i[claim_id_i - 1]) begin

                    $error(
                        "Priority violation: a higher-priority source exists"
                    );

                end
            end
        end
    end

endmodule
