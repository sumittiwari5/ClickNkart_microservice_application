import React, { useEffect, useState } from 'react'
import { NavLink, useParams,useNavigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';

export default function UpdateProduct() {
    const {register, handleSubmit, reset} = useForm();
    const navigate = useNavigate();
      const params = useParams();
  // console.log("Details Id:",params.id);
  const [productDetails, setProductDetails] = useState(null);
 
  const token = localStorage.getItem("jwtToken");
  

  useEffect(() => {
    fetch(`${process.env.REACT_APP_API_URL}/api/products/${params.id}`)
      .then(resp => resp.json())
      .then(data => {
        // console.log(data);
        setProductDetails(data);
      })
  }, []);
   
  useEffect(()=>{
    if(productDetails){
      reset(productDetails)
    }
  },[productDetails, reset]);


  function updateProductInDb(formData){
      fetch(`${process.env.REACT_APP_API_URL}/api/products/${params.id}`,{
        headers: {
                  "Content-Type":"application/json",
                  "Authorization":`Bearer ${token}`
                },
        method:"PUT",
        body:JSON.stringify(formData)
      })
      .then(resp => {
        // console.log(resp); 
        if(resp.ok)  {
          alert("Product updated !!");
          navigate("/");
        }     
      })
  }
    return (
      productDetails && 
        <div className='col-md-4 mx-auto border border-primary shadow rounded p-3 m-3'>
            <form onSubmit={handleSubmit(updateProductInDb)}>
                <h2>Update Product</h2>
                <div className="mb-3">
                    <label  className="form-label">Name</label>
                    <input type="text" className="form-control" 
                    {...register('name')} />                    
                </div>
                <div className="mb-3">
                    <label  className="form-label">Category</label>
                    <input type="text" className="form-control" 
                    {...register('category')} />                    
                </div>
                <div className="mb-3">
                    <label  className="form-label">Description</label>
                    <textarea className="form-control" 
                    {...register('description')}></textarea>                   
                </div>
                <div className="mb-3">
                    <label  className="form-label">Image Path</label>
                    <input type="text" className="form-control" 
                    {...register('imageUrl')} />                    
                </div>
                <div className="mb-3">
                    <label  className="form-label">Price (in Rs.)</label>
                    <input type="text" className="form-control" 
                    {...register('price')} />                    
                </div>

                <button type="submit" className="btn btn-primary">Update Product</button>
            </form>
        </div>
    )
}
