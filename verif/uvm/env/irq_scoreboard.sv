class irq_scoreboard extends uvm_component;

    `uvm_component_utils(irq_scoreboard)

    uvm_analysis_imp #(reg_item, irq_scoreboard) reg_imp;

    irq_ref_model model;

    int unsigned checks;
    int unsigned errors;

    function new(
        string name,
        uvm_component parent
    );
        super.new(name, parent);

        reg_imp = new("reg_imp", this);
        checks = 0;
        errors = 0;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        model = irq_ref_model::type_id::create("model");
    endfunction

    function void write(reg_item tr);

        int expected_id;

        checks++;

        if (tr.write) begin

            // Priority configuration.
            if (tr.addr < 'h100 &&
                tr.addr[1:0] == 0 &&
                tr.addr / 4 < model.n_src) begin

                model.priority[tr.addr / 4] =
                    tr.wdata & 7;

            end

            // Enable configuration.
            else if (tr.addr == 'h2000) begin

                for (int i = 0; i < model.n_src; i++) begin
                    model.enabled[tr.target][i] =
                        tr.wdata[i];
                end

            end

            // Threshold configuration.
            else if (tr.addr == 'h3000) begin

                model.threshold[tr.target] =
                    tr.wdata & 7;

            end

            // Completion state updates must be coordinated
            // with the model's outstanding-claim bookkeeping.
        end

        else if (tr.addr == 'h3004) begin

            expected_id =
                model.expected_claim(tr.target);

            if (tr.rdata !== expected_id) begin

                errors++;

                `uvm_error(
                    "IRQ_SB",
                    $sformatf(
                        "Target=%0d expected claim=%0d got=%0d",
                        tr.target,
                        expected_id,
                        tr.rdata
                    )
                )

            end

            if (expected_id > 0) begin
                model.pending[expected_id - 1] = 0;
            end

        end

    endfunction

    function void report_phase(uvm_phase phase);

        `uvm_info(
            "IRQ_SB",
            $sformatf(
                "Checks=%0d Errors=%0d",
                checks,
                errors
            ),
            UVM_LOW
        )

    endfunction

endclass
