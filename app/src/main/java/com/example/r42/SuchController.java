package com.example.r42;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SuchController {

  @RequestMapping("/hello")
  // retrieve AZ from EC2 metadata endpoint
  @ResponseBody
  public static String main(String[] args) throws Exception {
    URL metadata = new URL("http://169.254.169.254/latest/meta-data/placement/availability-zone/");
    URLConnection yc = metadata.openConnection();
    BufferedReader in = null;
    in = new BufferedReader(new InputStreamReader(yc.getInputStream()));
    String inputLine = "";
    String returnvalue = "";
    while ((inputLine = in.readLine()) != null) {
      returnvalue += inputLine;
    }
    in.close();
    System.out.println(returnvalue);
    return returnvalue;
  }

}
