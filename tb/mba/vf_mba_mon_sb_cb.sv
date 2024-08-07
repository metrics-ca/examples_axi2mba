//----------------------------------------------------------------------
/**
 * @file vf_mba_mon_sb_cb.sv
 * @brief Defines VF MBA monitor scoreboard callback class.
 */
/*
 * Copyright (C) 2007-2016 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _VF_MBA_MON_SB_CB_SV_
`define _VF_MBA_MON_SB_CB_SV_
`pragma protect begin_protected
`pragma protect version=1
`pragma protect encrypt_agent="dvlencrypt"
`pragma protect encrypt_agent_info="Metrics Design Automation Inc. P1735 encryptor tool"
`pragma protect author="author-a"
`pragma protect author_info="author-a-details"
`pragma protect data_method="aes256-cbc"
`pragma protect key_keyowner="Metrics Technologies Inc."
`pragma protect key_keyname="DSim"
`pragma protect key_method="rsa"
`pragma protect key_block
ljpKK4nWt3GJS3SUiSPuy6snLhRZZ3uFfSfJ+on2KhZopZU2NZWj+Wh4TLgoyHYO
xUJCURvGjRbKzB7J8a1wRkfFl+HzOlXx2DagoLd5XJQGE0cqe3M4QH1udNy6+Ixw
oVW7oWEFPgsSGU9GIiqBEtg2cBTTLybvzsmit8u5ftl4HB9B4VVut1RirqoDL9S/
zqKL+PpIum/KtQCYAO83Rj1rBRigRu3HoK5oHK5cF1E9EKbHZIm6t2IBXwERZeEH
29S32FDmgz+kfDW84hSLBunbwCWvQthbVhf1Nec+1mavzwq0K3CEXHW0A4UXiMAh
TR8qzrcfQ4HdhSDajmy4mQ==
`pragma protect data_block
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
h/dv4qo1uNGtGqpVBLk9hg==
`pragma protect end_protected

`endif // `ifndef _VF_MBA_MON_SB_CB_SV_


