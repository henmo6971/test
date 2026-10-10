resource "aws_key_pair" "tester" {
  key_name   = "tester"
  public_key = file("~/.ssh/id_ed25519.pub") # your local public key
}
