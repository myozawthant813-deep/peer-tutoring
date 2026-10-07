package com.fis.peerlink.Models;

import jakarta.persistence.*;

@Entity
@Table(name = "user")
public class User {

    @Id
    @GeneratedValue (strategy = GenerationType.IDENTITY)

    private long id;
    
    private String name;

    @Column (nullable = false, unique = true)
     private String email;
     private String password;
     private String university;
     private String major;
     private Integer year;

     @Column (length = 500)
     private String bio;
     private String profileImage;
     private String role;
     private Integer peerScore;


     public User(){

     }
     public long getId() {
        return id;
    }


    public void setId(long id) {
        this.id = id;
    }

     public String getName(){
        return name;
     }

     public void setName(String name){
        this.name = name;
     }

     public String getEmail(){
        return email;
     }

     public void setEmail(String email){
        this.email = email;
     }

     public String getPassword(){
        return password;
     }

     public void setPassword(String password){
        this.password = password;
     }
     public String getUniversity(){
        return university;
     }

     public void setUniversity(String university){
        this.university = university;
     }

     public String getMajor(){
        return major;
     }

     public void setMajor(String major){
        this.major = major;
     }

     public Integer getYear(){
        return year;
     }

     public void setYear(Integer year){
        this.year = year;
     }

     public String getBio(){
        return bio;
     }

     public void setBio (String bio){
        this.bio = bio;
     }

     public String getProfileImage(){
        return profileImage;
     }

     public void setProfileImage(String profileImage){
        this.profileImage = profileImage;
     }

     public String getRole(){
        return role;
     }

     public void setRole (String role){
        this.role = role;
     }

     public Integer getPeerScore(){
        return peerScore;
     }

     public void setPeerScore(Integer peerScore){
        this.peerScore = peerScore;
     }
     



    
}