import React, { useEffect, useMemo, useState } from 'react'
import {NavLink} from 'react-router-dom';

export default function CartList() {

    const [cartList, setCartList] = useState(null);
    const userId = localStorage.getItem("userId");
    const token = localStorage.getItem("jwtToken");

    useEffect(() => {
        fetch(`${process.env.REACT_APP_API_URL}/api/users/${userId}/cartList`)
            .then(resp => resp.json())
            .then(data => {
                // console.log(data._embedded.carts);
                setCartList(data._embedded.carts);
            })
    }, []);


    const {count, total} = useMemo(()=>{
        let count=0;
        let total=0;
         if(cartList){
            count = cartList.length;
            for(let cart of cartList){
                total += cart.quantity * cart.product.price;
            }           
         }
        return {count,total};
    },[cartList])

    function deleteCart(id){
        fetch(`${process.env.REACT_APP_API_URL}/api/carts/${id}`,{
            headers:{"Authorization":`Bearer ${token}`},
            method:"DELETE"
        })
        .then(resp=>{
            // console.log(resp);
            if(resp.ok){
                alert("Product deleted from Cart !!")
                const updatedCartList = cartList.filter(cart => cart.id !== id)
                setCartList(updatedCartList)
            }
        })
    }

    function updateQuantity(event, cart){
        // console.log(event);
        const q = parseInt(event.target.value);
        
        const updatedCart = {
            // "id":cart.id,
            "user":`${process.env.REACT_APP_API_URL}/api/users/${userId}`,
            "product":`${process.env.REACT_APP_API_URL}/api/products/${cart.product.id}`,
            "quantity":q
        }
        fetch(`${process.env.REACT_APP_API_URL}/api/carts/${cart.id}`,{
            headers:{
                "Content-Type":"application/json",
                "Authorization":`Bearer ${token}`
            },
            method:"PUT",
            body:JSON.stringify(updatedCart)
        })
        .then(resp => {
            // console.log(resp); 
            if(resp.ok){
                const updatedCartList = cartList.map(cartObj => {
                    if (cartObj.id === cart.id ){
                        cartObj.quantity = q;
                    }
                    return cartObj;
                })
                setCartList(updatedCartList);
            }           
        })
    }
    return (
        <div className='row mt-2'>
            <div className='col-9'>
                <h2 className='bg-warning'>List of Products</h2>
                {
                    cartList &&
                    cartList.map(cart =>
                        <div className='row mt-2 p-3' key={cart.id}>
                            <div className="card">                                
                                <div className='row'>
                                    <div className='col-md-4'>
                                        <img src={cart.product.imageUrl} height="200px"/>
                                    </div>
                                    <div className='col-md-8'>
                                        <div className="card-body">
                                            <h5 className="card-title">Name: {cart.product.name}</h5>
                                            <h5 className="card-title">Category: {cart.product.category}</h5>
                                            <p className="card-text">{cart.product.description}</p>
                                            <p><strong>Rs. {cart.product.price}</strong></p>
                                            <p>
                                                Quantity: <input type="number" className='col-1 ' min="1" 
                                                value={cart.quantity} 
                                                onChange={()=>updateQuantity(window.event, cart)}/>
                                                <button className="ms-2 btn btn-danger" onClick={()=>deleteCart(cart.id)}>Delete</button>
                                            </p>
                                            
                                        </div>
                                    </div>

                                </div>
                            </div>
                        </div>)
                }
            </div>
            <div className='col-3'>
                <h2 className='bg-warning'>Summary</h2>
                <h3>No of Items: {count}</h3>
                <h3>Total Bill: {total}</h3>
                <NavLink className='btn btn-success' to={"/payment"}>Confirm Order</NavLink>
            </div>
        </div>
    )
}
