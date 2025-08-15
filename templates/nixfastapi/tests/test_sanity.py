from nixfastapi import hello

def test_hello(capsys):
    hello()
    captured = capsys.readouterr()
    assert captured.out == "Hello from nixfastapi!\n❄️🐍💨\n"
    