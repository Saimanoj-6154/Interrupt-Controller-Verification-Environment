class intr_src_monitor extends uvm_component;

    `uvm_component_utils(intr_src_monitor)

    virtual irq_if vif;

    uvm_analysis_port #(intr_src_item) ap;

    function new(
        string name,
        uvm_component parent
    );
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual irq_if)::get(
                this, "", "vif", vif
            )) begin
            `uvm_fatal("NOVIF", "irq_if was not configured")
        end
    endfunction

    task run_phase(uvm_phase phase);
        intr_src_item tr;

        forever begin
            @(vif.intr);

            tr = intr_src_item::type_id::create("observed");

            // Snapshot the input vector for analysis.
            // Extend the transaction with a complete vector field
            // when implementing a production scoreboard.
            tr.source_id = 0;
            tr.level = vif.intr[0];
            tr.hold_cycles = 1;

            ap.write(tr);
        end
    endtask

endclass
