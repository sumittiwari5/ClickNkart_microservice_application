import React, { useEffect, useMemo, useState } from 'react'
import {NavLink, useNavigate} from 'react-router-dom';

export default function Payment() {
  const [cartList, setCartList] = useState(null);
      const userId = localStorage.getItem("userId");
    //   const token = localStorage.getItem("jwtToken");
    const navigate = useNavigate();
  
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



    const startPayment = async () => {
        const token = localStorage.getItem("jwtToken");

        if (!token) {
        alert("Please login first.");
        return;
        }

        // 1. Create order
        const res = await fetch(`${process.env.REACT_APP_API_URL}/api/create-order`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`,
        },
        body: JSON.stringify({ amount: total }),
        });

    const data = await res.json();
    // console.log("received data from SB: ", data);
    if (!res.ok) {
      alert("Order creation failed: " + JSON.stringify(data));
      return;
    }

    // 2. Open Razorpay popup
    const options = {
      key: data.key,
      amount: data.amount,
      currency: "INR",
      name: "My App",
      description: "Payment Test",
      order_id: data.orderId,

      handler: async function (response) {
        // 3. Verify payment using backend
        fetch(`${process.env.REACT_APP_API_URL}/api/verify`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`,
          },
          body: JSON.stringify(response),
        })
          .then((resp) => {
            if (resp.ok) {
              console.log(JSON.stringify(resp.data));
              alert("Order Placed Successfully!");
              navigate("/");
            }
            else {
              alert("Payment Verification Failed!");
            }
            return resp.json();
          })
          .then((data) => console.log(data));
      },

      prefill: {
        name: "Test User",
        email: "test@example.com",
        contact: "9769094244",
      },
    };

    const rzp = new window.Razorpay(options);
    rzp.open();
  };

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
                                                  Quantity: {cart.quantity}                              

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
                  <NavLink className='btn btn-success m-2'
                  to={"/mycart"}>Back</NavLink>
                  <button className='btn btn-success m-2' onClick={startPayment}>Make Payment</button>
              </div>
          </div>
      )
  }
  
