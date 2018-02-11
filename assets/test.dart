class BinaryData {
  BinaryData();

  void addUInt32(int data) {

  }

  int readUInt32() {

  }
}

class ParentClass {
  /// Id
  final int id;

  /// Constructor
  ParentClass(this.id, String subid);
}

class TestClass extends ParentClass {  
  /// Name
  final String name;

  /// Constructor
  TestClass(this.name, String mail) : super(0, "subid") {
    print(mail);
  }

  /// Unpack
  void unpack(BinaryData data) {
    final d1 = data.readUInt32();
    final d2 = data.readUInt32();    
    print(d1 + d2);
  }

  /// Pack to binary data
  BinaryData pack() {
    var d = 2;
    return new BinaryData();
  }
}