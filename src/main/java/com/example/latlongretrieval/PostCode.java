package com.example.latlongretrieval;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.example.latlongretrieval.Place;
import java.util.*;
import lombok.Data;

@JsonIgnoreProperties(ignoreUnknown = true)
@Data
public class PostCode{

  @JsonProperty(value = "post code")
  private String postCode;

  @JsonProperty(value = "country")
  private String country;

  @JsonProperty(value = "places")
  private List<Place> places;
}
