class intr_src_driver extends uvm_driver #(intr_src_item);

    `uvm_component_utils(intr_src_driver)

    virtual irq_if vif;

    function new(
        string name,
        uvm_component parent
    );
        super.new(name, parent);
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
            seq_item_port.get_next_item(tr);

            repeat (tr.hold_cycles) begin
                @(negedge vif.clk);

                if (tr.source_id < $bits(vif.intr)) begin
                    vif.intr[tr.source_id] <= tr.level;
                end
            end

            seq_item_port.item_done();
        end
    endtask

endclass
