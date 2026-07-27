import React, { useEffect, useState } from 'react'
import { NavLink, useNavigate } from 'react-router-dom';

export default function MyOrders() {

    const [myOrders, setMyOrders] = useState(null);
    const navigate = useNavigate();
    const userId = localStorage.getItem("userId");

    useEffect(()=>{
        fetch(`${process.env.REACT_APP_API_URL}/api/users/${userId}/myorders`)
        .then(resp => resp.json())
        .then(data => {
            console.log(data);
            setMyOrders(data._embedded.orderses);
    })
    },[]);

  return (    
      myOrders && 
      <div className='col-md-6 mx-auto mt-4'>
      <table className=" table table-striped">
        <thead>
          <tr>
            <th scope="col">OrerId</th>
            <th scope="col">Order Date</th>
            <th scope="col">Bill Amount</th>
          </tr>
          </thead>
          <tbody>
            {
              myOrders.map(ord => 
                 <tr key={ord.orderId}>
                  <td>
                    <button className='btn btn-link'
                    onClick={()=>navigate("/order-details",{state:ord.orderId})}>{ord.orderId}</button>
                  </td>
                  <td>{new Date(ord.orderDate).toLocaleString()}</td>
                  <td>₹ {ord.totalBill}</td>
                </tr>
              )
            }
          </tbody>        
      </table>
    </div>
  )
}
