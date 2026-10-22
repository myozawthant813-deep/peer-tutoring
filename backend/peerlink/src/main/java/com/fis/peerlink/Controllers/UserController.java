package com.fis.peerlink.Controllers;

import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.*;

import com.fis.peerlink.Models.User;
import com.fis.peerlink.Services.UserService;




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


    
    @PostMapping("/login")
public Map<String, Object> login(@RequestBody Map<String, String> request) {
    String email = request.get("email");
    String password = request.get("password");

    return userService.loginWithToken(email, password);
}

@PutMapping("/{id}/profile")
public User updateProfile(
        @PathVariable Long id,
        @RequestBody Map<String, Object> request) {

    return userService.updateProfile(id, request);
}

@GetMapping("/{id}")
public User getUserById(@PathVariable Long id) {
    return userService.getUserById(id);
}



    
}
