class reg_driver extends uvm_driver #(reg_item);

    `uvm_component_utils(reg_driver)

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
        reg_item tr;

        forever begin
            seq_item_port.get_next_item(tr);

            @(negedge vif.clk);

            vif.reg_valid  <= 1'b1;
            vif.reg_write  <= tr.write;
            vif.reg_addr   <= tr.addr;
            vif.reg_wdata  <= tr.wdata;
            vif.reg_target <= tr.target;

            @(negedge vif.clk);

            tr.rdata = vif.reg_rdata;
            vif.reg_valid <= 1'b0;

            seq_item_port.item_done();
        end
    endtask

endclass
