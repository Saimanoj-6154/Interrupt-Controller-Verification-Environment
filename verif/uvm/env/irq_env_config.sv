class irq_env_config extends uvm_object;

    `uvm_object_utils(irq_env_config)

    int unsigned n_src = 16;
    int unsigned n_tgt = 2;

    bit has_src_agent = 1;
    bit has_reg_agent = 1;

    function new(string name = "irq_env_config");
        super.new(name);
    endfunction

endclass
