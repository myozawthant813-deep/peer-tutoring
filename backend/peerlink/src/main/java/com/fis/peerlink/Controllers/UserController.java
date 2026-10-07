package com.fis.peerlink.Controllers;

import java.util.List;
import org.springframework.web.bind.annotation.*;

import com.fis.peerlink.Models.User;
import com.fis.peerlink.Services.UserService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;




@RestController
@RequestMapping ("/api/users")
@CrossOrigin (origins = "*")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService){
        this.userService = userService;
    }

    @PostMapping  
    public User creteUser(@RequestBody User user){
        return userService.creteUser(user);
    }

    @GetMapping
    public List<User> getAllUsers(){
        return userService.getAllUsers();
    }

    
}
