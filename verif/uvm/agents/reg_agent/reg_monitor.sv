class reg_monitor extends uvm_component;

    `uvm_component_utils(reg_monitor)

    virtual irq_if vif;
    uvm_analysis_port #(reg_item) ap;

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
        reg_item tr;

        forever begin
            @(posedge vif.clk);

            if (vif.reg_valid && vif.reg_ready) begin
                tr = reg_item::type_id::create("reg_observed");

                tr.write  = vif.reg_write;
                tr.addr   = vif.reg_addr;
                tr.wdata  = vif.reg_wdata;
                tr.rdata  = vif.reg_rdata;
                tr.target = vif.reg_target;

                ap.write(tr);
            end
        end
    endtask

endclass
