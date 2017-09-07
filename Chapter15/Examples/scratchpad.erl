-module(scratchpad).
-export([test/0]).

test() ->
  % Key = crypto:strong_rand_bytes(16),
  Key = <<227,79,123,63,70,178,97,116,26,25,98,188,32,40,7,173>>,
  % IV = crypto:strong_rand_bytes(16),
  IV = <<38,31,73,120,76,87,156,212,97,135,183,118,10,215,206,161>>,
  Input = <<"Sup World">>,
  EncryptedContent = crypto:block_encrypt(aes_cfb128, Key, IV, Input),
  DecryptedContent = crypto:block_decrypt(aes_cfb128, Key, IV, EncryptedContent).
