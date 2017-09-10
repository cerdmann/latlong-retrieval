package com.example.latlongretrieval;

import lombok.Data;

@Data
public class LatLong {

  private String city;
  private double longitude;
  private String state;
  private double latitude;
  private String zipcode;
  private String country;

  public LatLong( String city, double longitude, String state,
                  double latitude, String zipCode, String country) {
    this.city = city;
    this.longitude = longitude;
    this.state = state;
    this.latitude = latitude;
    this.zipcode = zipCode;
    this.country = country;
  }

}
