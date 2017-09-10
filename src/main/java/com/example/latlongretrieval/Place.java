package com.example.latlongretrieval;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@JsonIgnoreProperties(ignoreUnknown = true)
@Data
public class Place {
  
  @JsonProperty(value = "place name")
  private String name;

  @JsonProperty(value = "longitude")
  private double longitude;

  @JsonProperty(value = "state abbreviation")
  private String state;

  @JsonProperty(value = "latitude")
  private double latitude;
}
