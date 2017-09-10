package com.example.latlongretrieval;

import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.HttpStatusCodeException;
import java.util.*;

@RestController
public class LatLongController {

  @RequestMapping("byzip/{zipcode}")
  public LatLong findByZipCode(@PathVariable("zipcode") String zipCode) {

    PostCode apiResponse = getZippopotamusResponse(zipCode);

    String zip = apiResponse.getPostCode();
    Optional<Place> optional = apiResponse.getPlaces().stream().findFirst();

    Place place = optional.orElse(new Place());

    return new LatLong(place.getName(), place.getLongitude(), place.getState(),
                       place.getLatitude(), apiResponse.getPostCode(),
                       apiResponse.getCountry());
  }

  private PostCode getZippopotamusResponse(String zipCode) {

    RestTemplate restTemplate = new RestTemplate();
    String url = "http://api.zippopotam.us/us/" + zipCode;

    PostCode apiResponse;

    try {
      apiResponse = restTemplate.getForObject(url, PostCode.class);
    } catch (HttpStatusCodeException exception) {

      List<Place> places = new ArrayList<Place>();
      places.add(new Place());

      apiResponse = new PostCode();
      apiResponse.setPostCode(zipCode);
      apiResponse.setPlaces(places);
    }

    return apiResponse;

  }
}
