import React, { useState } from 'react'
import { useForm } from 'react-hook-form';
import { useNavigate } from 'react-router-dom';

export default function Register() {

  const {register, handleSubmit, formState:{errors}} = useForm({
    defaultValues: {
      username:'',
      email:'',
      password:'',
      confirmPassword:'',
      mobile:'',
      roles:[]
    }
  });
  const [ formError, setFormError] = useState(null);
  const navigate = useNavigate();
  // const [roles, setRoles] = useState(["ROLE_USER"]);

  // function updateRoles(event){
  //   console.log(event);
  //   if(event.target.checked){
  //     roles.push(event.target.value);
  //   }
  //   else {
  //     roles.pop(event.target.value);
  //   }
  //   console.log(roles);
    
  // }

  function registeruser(formData){
    console.log(formData); 
    if(formData.password !== formData.confirmPassword){
      setFormError("Password and Confirm Password must be same!!");
    }   
    // elseIf() - other validations, if any
    else {
      setFormError(null);
      // send the api request
      fetch(`${process.env.REACT_APP_API_URL}/api/register`,{
        headers:{"Content-Type":"application/json"},
        method:"POST",
        body: JSON.stringify(formData)
      })
      .then(resp => {
        // console.log("SERVER RESPOSE:",resp);
        return resp.json();
    })
      .then(data=>{
        // console.log("SERVER Data:",data);  
        if(data.status==400) {
          setFormError(data.message);
        }  
        else{
          alert("Registered successfully!! Plz login");
          navigate("/login");
        }   
      })
    }  
  }

  return (
    <div className='col-md-4 shadow border rounded m-3 p-3 mx-auto'>
      <form onSubmit={handleSubmit(registeruser)}>
        <h3>Register</h3>
        {
        formError &&
        <div className='alert alert-danger' role='alert'>
           {formError}
        </div>
        }
        <div className="mb-3">
          <label className="form-label">Username</label>
          <input type="text" className="form-control" 
          {...register('username',
          {required:{message:"Username is compulsory"}})} />
          
        </div>
        <div className="mb-3">
          <label className="form-label">Email address</label>
          <input type="email" className="form-control" 
          {...register('email',    
          {required:{message:"Email is compulsory"}}    )} />
        </div>
        <div className="mb-3">
          <label  className="form-label">Password</label>
          <input type="password" className="form-control" 
          {...register('password',   
            {required:{message:"Password is compulsory"}}      )} />
        </div>
        <div className="mb-3">
          <label  className="form-label">Confirm Password</label>
          <input type="password" className="form-control" 
          {...register('confirmPassword',  
           {required:{message:"Confirm Password is compulsory"}}          )} />
        </div>
        <div className="mb-3">
          <label  className="form-label">Mobile</label>
          <input type="text" className="form-control" 
          {...register('mobile',   
          {required:{message:"Mobile is compulsory"}} )} />
        </div>


        <div className="form-check" >
          <input className="form-check-input" type="checkbox" value="ROLE_ADMIN" id="checkDefault" {...register('roles')}/>
          <label className="form-check-label" htmlFor="checkDefault">
            ADMIN
          </label>
        </div>
        <div className="form-check">
          <input className="form-check-input" type="checkbox" value="ROLE_USER" id="checkChecked"  {...register('roles')} />
          <label className="form-check-label" htmlFor="checkChecked">
            USER
          </label>
        </div>


        <button type="submit" className="btn btn-primary">Register</button>
      </form>
    </div>
  )
}
