package com.example.latlongretrieval;

import org.junit.jupiter.api.Test;
import java.util.List;
import static org.junit.jupiter.api.Assertions.assertEquals;

class PostCodeTest {

  @Test
  void canConstructPostCode() {
    PostCode postCode = new PostCode();
    postCode.setPostCode("90210");
    postCode.setCountry("United States");
    postCode.setPlaces(List.of(new Place()));

    assertEquals("90210", postCode.getPostCode());
    assertEquals("United States", postCode.getCountry());
    assertEquals(1, postCode.getPlaces().size());
  }
}
