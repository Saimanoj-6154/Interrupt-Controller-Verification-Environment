class irq_ref_model extends uvm_object;

    `uvm_object_utils(irq_ref_model)

    int unsigned n_src = 16;
    int unsigned n_tgt = 2;

    int unsigned priority [16];
    int unsigned threshold[2];

    bit pending[16];
    bit enabled[2][16];

    function new(string name = "irq_ref_model");
        super.new(name);
    endfunction

    function int expected_claim(int tgt);

        int best_id;
        int best_priority;

        best_id = 0;
        best_priority = 0;

        for (int i = 0; i < n_src; i++) begin

            if (pending[i] &&
                enabled[tgt][i] &&
                priority[i] > threshold[tgt] &&
                priority[i] > best_priority) begin

                best_priority = priority[i];
                best_id = i + 1;
            end
        end

        // Zero means no eligible interrupt.
        // Strict comparison preserves the lower ID on a tie.
        return best_id;

    endfunction

    function void reset_model();

        foreach (priority[i])
            priority[i] = 0;

        foreach (pending[i])
            pending[i] = 0;

        foreach (threshold[t])
            threshold[t] = 0;

        foreach (enabled[t, i])
            enabled[t][i] = 0;

    endfunction

endclass
