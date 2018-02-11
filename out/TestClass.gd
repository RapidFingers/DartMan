extends Reference

var name

func _init(name, mail).(0,"subid"):
    self.name = name
    print(mail)

func unpack(data):
    var d1 = data.readUInt32()
    var d2 = data.readUInt32()
    print(d1 + d2)

func pack():
    var d = 2
