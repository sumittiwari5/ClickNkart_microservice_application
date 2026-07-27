import React from 'react';
import {useForm} from 'react-hook-form';
import {useNavigate } from 'react-router-dom';


export default function AddProduct() {

    const {register, handleSubmit} = useForm();
    const navigate = useNavigate();

    function addNewProduct(formData){
        console.log(formData);    
        const token = localStorage.getItem("jwtToken")  ;  

        fetch(`${process.env.REACT_APP_API_URL}/api/products`,{
            headers: {
                "Content-Type":"application/json",
                "Authorization":`Bearer ${token}`
            },
            method:"POST",
            body:JSON.stringify(formData)
        })
        .then(resp => {
            if(resp.status ==201)
            {
                alert("product added successfully !!");
                navigate("/");
            }
        })
    }

    return (
        <div className='col-md-4 mx-auto border border-primary shadow rounded p-3 m-3'>
            <form onSubmit={handleSubmit(addNewProduct)}>
                <h2>Add New Product</h2>
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

                <button type="submit" className="btn btn-primary">Add Product</button>
            </form>
        </div>
    )
}
