package com.fis.peerlink.Controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController 
public class TestController {

    @GetMapping("/api/test")
    public String test(){
        
        return "Peerlink backend is working";
    }
    
}
