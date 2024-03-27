//----------------------------------------------------------------------
/**
 * @file vpr_cfg.sv
 * @brief Defines Configuration class.
 */
/*
 * Copyright (C) 2007-2011 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _VPR_CFG_SV_
`define _VPR_CFG_SV_
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
TQksdhUXLKS3PbrJFPg8MSGXI8MkzuEkUcyYPDzUPVYEWLDJS5xJ8jpCLK38tISr
8WU8t3SGrVWcCyH9KPCUxgC5jG82kyQQ3DHdFxe+/FZMG6P5mppuuj9QcA+8D27I
sJfV4jtODPG7pBYYg8wfGbHmdBDGALjVSDH8/gOd5JI4RoNMfAEBK2n0Tgs0TCJe
iUczKrEz3/Oiidl7ACrvL4hngEEve+NHtUFle7BIuonVimrJsdEznZ+OqgfDwESv
l7fPw4vrydDI4P4kE4LgGTKOFF7uPXhjstbZLFLk8CV4sJnm7ojD3qjq6yDQ4LfD
i4lizyNtZhawGfxATTXwgg==
`pragma protect data_block
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
KZlQ+QZ4tw1Bju8polhp7g==
`pragma protect end_protected

`endif // `ifndef _VPR_CFG_SV_


