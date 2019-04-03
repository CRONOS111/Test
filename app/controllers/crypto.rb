require 'openssl'

class Crypt
  def self.enc file, pass, salt
    mess = OpenSSL::Cipher.new('aes-256-cbc')
    mess.encrypt
    mess.pkcs5_keyivgen pass, salt
    encrypted = mess.update File.binread(file)
    encrypted << mess.final
    File.binwrite file, encrypted
  end
  def self.dec file, pass, salt
    mess = OpenSSL::Cipher.new('aes-256-cbc')
    mess.decrypt
    mess.pkcs5_keyivgen pass, salt
    decrypted = mess.update File.binread(file)
    decrypted << mess.final
    File.binwrite file, decrypted
  end
end
