import React, { useEffect, useState } from 'react'
import { NavLink, useParams } from 'react-router-dom';
import { useNavigate } from 'react-router-dom';

export default function ProductDetail() {
  const params = useParams();
  // console.log("Details Id:",params.id);
  const [productDetails, setProductDetails] = useState(null);
  const roles  = localStorage.getItem("roles");
  const token = localStorage.getItem("jwtToken");
  const userId = localStorage.getItem("userId");
  const navigate = useNavigate();

  useEffect(() => {
    fetch(`${process.env.REACT_APP_API_URL}/api/products/${params.id}`)
      .then(resp => resp.json())
      .then(data => {
        // console.log(data);
        setProductDetails(data);
      })
  }, []);

  function deleteProduct(){
    const c = window.confirm("Do you really want to delete product '"+productDetails.name+"' ?");
    if(c){
      fetch(`${process.env.REACT_APP_API_URL}/api/products/${params.id}`,
        {
          headers: {"Authorization":`Bearer ${token}`},
          method:"DELETE"
        }
      )
      .then(resp => {
        alert("product deleted successfully !!");
        navigate("/");
      })
      // .then(data =>{
      //   console.log(data);        
      // })
    }
  }

  function addToCart(){
    if(roles && roles.includes("USER")){
      // add to cart
      const requestBody = {
        "user":  `${process.env.REACT_APP_API_URL}/api/users/${userId}`,
        "product": `${process.env.REACT_APP_API_URL}/api/products/${params.id}`
      }
     fetch(`${process.env.REACT_APP_API_URL}/api/carts`,{
        headers:{
              "Content-Type":"application/json",
              "Authorization":`Bearer ${token}`
            },
        method:"POST",
        body: JSON.stringify(requestBody)
      })
      .then(resp => {
        console.log(resp);        
        alert("Product added to Cart");
        navigate("/");
      })
    }
    else {
      alert("Please login first for shopping");
      navigate("/login")
    }
  }

  return (
    productDetails && 
    <div className=" card mb-3">
      <div className='row'>
      <div className='col-md-4'>
        <img src={productDetails.imageUrl} 
        height="250px"
        className="card-img-top" alt="could not download the image" />
      </div>
      <div className='col-md-8'>
        <div className="card-body">
          <h5 className="card-title">{productDetails.name}</h5>
          <h5 className="card-title">{productDetails.category}</h5>
          <p className="card-text">{productDetails.description}</p>
          <p className="card-text">
            <strong className="text-body-secondary">{productDetails.price}</strong></p>
          
            <button  className='btn btn-warning m-2' onClick={addToCart}><i className="bi bi-cart-plus-fill "></i></button>
        
          { roles && roles.includes("ADMIN") &&
          <>
          <NavLink className='btn btn-warning m-2' to={`/update/${params.id}`}><i className="bi bi-pencil-fill "></i></NavLink>
          <button className='btn btn-danger m-2'
          onClick={deleteProduct}><i className="bi bi-trash3-fill"></i></button>
          </>
          }       
        </div>
      </div>
    </div>
</div>
  )
}
