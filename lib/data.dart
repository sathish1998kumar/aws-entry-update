class Sathish_Class {
  dynamic vehicle_no;
  dynamic driver_name;
  dynamic imei;
  dynamic date;
  dynamic vehicles;



  Sathish_Class(
      {
        this.vehicle_no,
        this.driver_name,
        this.imei,
        this.date,
        this.vehicles,
       });

  Sathish_Class.fromJson(Map<String, dynamic> json) {
    vehicle_no = json['vehicle_no'];
    driver_name = json['driver_name'];
    imei = json['imei'];
    date = json['date'];
    vehicles = json['vehicles'];

  }
//

// }
}


