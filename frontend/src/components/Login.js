import React, { useState } from 'react'
import {useForm} from 'react-hook-form';
import {useNavigate} from 'react-router-dom';
import {jwtDecode} from 'jwt-decode';

export default function Login() {
  const {register, handleSubmit} = useForm();
  const navigate = useNavigate();
  const [loginError, setLoginError] = useState(null);

  function doLogin(formData){
    console.log(formData);
    // send api request
    fetch(`${process.env.REACT_APP_API_URL}/api/login`,{
      headers:{"Content-Type":"application/json"},
      method:"POST",
      body:JSON.stringify(formData)
    })
    .then(resp => {
      console.log("SERVER RESPONSE:",resp);
      if(resp.status==401){
        setLoginError("please provide correct details to login");        
      }
      return resp.json();      
    })
    .then(data => {
      console.log("server data:",data); 
      if(data.jwtToken){
        const token = data.jwtToken;
        localStorage.setItem("jwtToken",token);
        // user deatils - id, email, roles
        const decodedToken = jwtDecode(token);
        // console.log(decodedToken.sub);
        const tokenSubject  = decodedToken.sub;// string containing subject
        // '5,sumit,[ROLE_ADMIN,ROLE_USER]'
        const userId = tokenSubject.split(",")[0];
        const username = tokenSubject.split(",")[2];
        const roles = tokenSubject.split("[")[1];
        // string containing 'ROLE_USER, ROLE_ADMIN]'
        localStorage.setItem("userId",userId);
        localStorage.setItem("username",username);
        localStorage.setItem("roles",roles);
        // navigate("/");
        window.location.href="/";
      }     
    })
  }


  return (
    <div className='col-md-4 shadow border rounded m-3 p-3 mx-auto'>
      <form onSubmit={handleSubmit(doLogin)}>
        <h3>Login</h3>
        {
          loginError && 
          <div className='alert alert-danger' role='alert'>
            {loginError}
          </div>
        }
        <div className="mb-3">
          <label className="form-label">Email address</label>
          <input type="email" className="form-control" 
          {...register('email')} />
        </div>
        <div className="mb-3">
          <label  className="form-label">Password</label>
          <input type="password" className="form-control" 
          {...register('password')} />
        </div>
        <button type="submit" className="btn btn-primary">Login</button>
      </form>
    </div>
  )
}
