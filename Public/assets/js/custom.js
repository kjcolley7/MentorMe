var rating = 0;
//localStorage.setItem('logged', 0);

$(document).ready(function() {
    var email = localStorage.getItem("email");
    var curSignedIn = localStorage.getItem("name");
    var loggedIn = localStorage.getItem("islogged") == 1;
    SetNavbarSignIn(loggedIn);
    
    //loading profile
    if(window.location.pathname == "/profile.html"){
        var profileToLoad = localStorage.getItem("profileToLoad");
        var description = localStorage.getItem("description");
        var name = curSignedIn; //Get name of profile to load
        var city = localStorage.getItem("city");
        var age = localStorage.getItem("age");
        var rating = 3;
        var ownProfile = (name == profileToLoad);
        
        var nameHeading = document.getElementById('nameHeading');
        nameHeading.innerHTML = name;
        
        setProfileStars(rating);
        
        var namesProfile = document.getElementById('namesProfile');
        namesProfile.innerHTML = (name+"'s Profile <br>"+age);
        
        var cityHolder = document.getElementById('cityPlaceHolder');
        cityHolder.innerHTML += city;
        
        var details = document.getElementById('details');
        details.innerHTML = description;
        
        var editButton = document.getElementById('editButton');
        console.log()
        if(ownProfile)
            editButton.style.display = 'inline';
        else
            editButton.style.display = 'none';
  }
});

$("#profileLink").click(function(e){
    localStorage.setItem("profileToLoad", localStorage.getItem("name"));    
});

$("#done").click(function(e){
    var age = document.getElementById('ageEdit');
    var email = document.getElementById('emailEdit');
    var name = document.getElementById('nameEdit');
    var password = document.getElementById('passwordEdit');
    var confirmPassword = document.getElementById('confirmpasswordEdit');
    
    if(password.value != confirmPassword.value){alert('Passwords do not match'); return;}

    localStorage.setItem("email", email.value);
    localStorage.setItem("password", password.value);
    localStorage.setItem("name", name.value);
    localStorage.setItem("age", age.value);
    
    window.location.replace('profile.html');
});

$("#signup").click(function(e){
    var email = document.getElementById("email");
    localStorage.setItem("email", email.value);
    
    var password = document.getElementById("password");
    localStorage.setItem("password", password.value);
    
    var name = document.getElementById("firstName");
    localStorage.setItem("name", name.value);
    
    var age = document.getElementById("age");
    localStorage.setItem("age", age.value);
    
    var city = document.getElementById("city");
    localStorage.setItem("city", city.value);
    
});

$("#signed").click(function(e){
    var username = document.getElementById("username");
    var pass = document.getElementById("pass");
    
    if((localStorage.getItem("email") == username.value) && (localStorage.getItem("password") == pass.value))
    {
        alert('Youre a hacker');
        localStorage.setItem("islogged", 1);
        window.location.replace('index.html');
    }
    
    else
    {
        //window.location.replace('login.html');
        $('#login_error').show();
    }
});

$("#sign_out_button").click(function(e){
  localStorage.removeItem("username");
  localStorage.setItem("islogged", 0);
});

$("#stars").click(function(e){
    
        var leftSide = $(this).offset().left;
        var rightSide = leftSide + $(this).width()
        var length = rightSide - leftSide;
        var xClick = e.pageX - leftSide;
    
        var rating = Math.ceil(xClick/length*5);
    
       if(rating > 5)
           rating = 5;
        if(rating < 0)
            rating = 0;
    
        console.log(rating);
    
        
        var newText = '', i;
        for(i = 0; i < rating; i++)
            newText += '★'
        for(i = i; i < 5; i++)
            newText += '☆'
        $(this).html(newText);
});
                              
$("#categorySubmit").click(function(e){
    AddCustomTag();    
   $('#addOtherModal').modal('hide');
});

$("#submit").click(function(e){
    listSelectedTags = GetListOfTags();
    
    if(listSelectedTags.length == 0) {
        alert("You must choose at least one category");
        return;
    }
    else {
        console.log("Selected tags: ");
        
        //idk send this thing to the back end or something
        for(var i = 0; i < listSelectedTags.length; i++)
            console.log(listSelectedTags[i]+" ");
        
        window.location.href = "profile.html";
    }
});

function AddCustomTag()
{ 
   var newCategory = $("#customCategory").val();
   var tagsCol = $("#tags");
   tagsCol.prepend('<button class="btn btn-primary active" type="button" data-toggle="button" aria-pressed="true">'+newCategory+'</button>');

}

function GetListOfTags()
{
    var row = document.getElementById('tags');
    var tags = row.getElementsByTagName('*');
    var list = []
    
    for(var i = 0; i < (tags.length - 1); i++)
        if(tags[i].getAttribute("aria-pressed") == "true")
            list.push(tags[i].innerHTML);
    
    return list;
}

function setProfileStars(rating)
{
    var starOne = document.getElementById('star_one');
    var starTwo = document.getElementById('star_two');
    var starThree = document.getElementById('star_three');
    var starFour = document.getElementById('star_four');
    var starFive = document.getElementById('star_five');
    
    rating = Math.ceil(rating);

    switch(rating){
        case 0:
            starOne.setAttribute('class', 'fa fa-star-o');
            starTwo.setAttribute('class', 'fa fa-star-o');
            starThree.setAttribute('class', 'fa fa-star-o');
            starFour.setAttribute('class', 'fa fa-star-o');
            starFive.setAttribute('class', 'fa fa-star-o');
            break;
        case 1:
            starOne.setAttribute('class', 'fa fa-star');
            starTwo.setAttribute('class', 'fa fa-star-o');
            starThree.setAttribute('class', 'fa fa-star-o');
            starFour.setAttribute('class', 'fa fa-star-o');
            starFive.setAttribute('class', 'fa fa-star-o');
            break;
        case 2:
            starOne.setAttribute('class', 'fa fa-star');
            starTwo.setAttribute('class', 'fa fa-star');
            starThree.setAttribute('class', 'fa fa-star-o');
            starFour.setAttribute('class', 'fa fa-star-o');
            starFive.setAttribute('class', 'fa fa-star-o');
            break;
        case 3:
            starOne.setAttribute('class', 'fa fa-star');
            starTwo.setAttribute('class', 'fa fa-star');
            starThree.setAttribute('class', 'fa fa-star');
            starFour.setAttribute('class', 'fa fa-star-o');
            starFive.setAttribute('class', 'fa fa-star-o');
            break;
        case 4:
            starOne.setAttribute('class', 'fa fa-star');
            starTwo.setAttribute('class', 'fa fa-star');
            starThree.setAttribute('class', 'fa fa-star');
            starFour.setAttribute('class', 'fa fa-star');
            starFive.setAttribute('class', 'fa fa-star-o');
            break;
        default:
            starOne.setAttribute('class', 'fa fa-star');
            starTwo.setAttribute('class', 'fa fa-star');
            starThree.setAttribute('class', 'fa fa-star');
            starFour.setAttribute('class', 'fa fa-star');
            starFive.setAttribute('class', 'fa fa-star');
            break;
    }
}

$("#cityInput").keydown(function(e){
    var keyPressed = event.keyCode || event.which;
    
    if(keyPressed != 13) return;
    
    //At this point the user pressed enter
    var city = document.getElementById('cityInput').value;
    
    var heading = document.getElementById('city_label');
    heading.innerHTML = city;
});

function CreateNewUserCard(username, listOfTags, description)
{
    var tagSpans;
    
    /*
    var newCard = '<div class="card"> <div class="card-body"> <a class="card-link" href="profile.html"><h4>'+username+'</h4></a><div class="container">'+tagSpans+'</div><p class="card-text">'+description+'</p></div></div>';
    */
    
    var newCard = document.createElement('div');
    newCard.setAttribute('class', 'card');
    
    var cardBody = document.createElement('div');
    cardBody.setAttribute('class', 'card-body');
    
    var headerLink = document.createElement('a');
    headerLink.setAttribute('class', 'card-link');
    headerLink.setAttribute('href', 'profile.html');
    
    var heading = document.createElement('h4');
    heading.innerHTML = username;
    
    var tagsDiv = document.createElement('div');
    tagsDiv.setAttribute('class', 'container');
    
    headerLink.append(heading);
    cardBody.append(headerLink);
    
    for(var i = 0; i < listOfTags.length; i++)
    {
        console.log(listOfTags[i]);
        var newSpan = document.createElement('span');
        newSpan.setAttribute('class', 'badge badge-secondary');
        newSpan.innerHTML = listOfTags[i];
        tagsDiv.append(newSpan);
    }
    
    cardBody.append(tagsDiv);
    
    var cardDesc = document.createElement('p');
    cardDesc.setAttribute('class', 'card-text');
    cardDesc.innerHTML = description;
    
    cardBody.append(cardDesc);
    
    newCard.append(cardBody);
    
    document.body.appendChild(newCard);    
}

function SetNavbarSignIn(signedIn)
{
    var login = document.getElementById('log_in_button');
    var signUp = document.getElementById('sign_up_button');
    var signOut = document.getElementById('sign_out_button');
    var profileButton = document.getElementById('profileLink');
    var messageButton = document.getElementById('messageButton');
    var becomeMentorButton = document.getElementById('becomeMentorButton');
    
    if(signedIn)
    {
        login.style.display = 'none'; 
        signUp.style.display = 'none'; 
        signOut.style.display = 'inline';
        profileButton.style.display = 'inline';
        messageButton.style.display = 'inline';
        becomeMentorButton.style.display = 'inline';
        
    }
    else
    {
        login.style.display = 'inline'; 
        signUp.style.display = 'inline'; 
        signOut.style.display = 'none';
        profileButton.style.display = 'none';
        messageButton.style.display = 'none';
        becomeMentorButton.style.display = 'none';
    }
}