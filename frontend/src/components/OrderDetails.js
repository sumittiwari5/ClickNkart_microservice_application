import React, { useEffect, useState } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'

export default function OrderDetails() {
  const location = useLocation();
  const ordId = location.state;
  const [details, setDetails] = useState(null);
  const navigate = useNavigate();

  useEffect(()=>{
      fetch(`${process.env.REACT_APP_API_URL}/api/orderDetails/${ordId}`)
      .then(resp => resp.json())
      .then(data=>{
        setDetails(data);
      });      
  },[])
  
  return (details &&
    <div className="card col-8 mx-auto shadow rounded mt-3">
      <div className="card-header">Order Details</div>
      <div className="card-body">
        <table className="table">
          <tbody>
            <tr>
              <th scope="col">Order Date</th>
              <td>{new Date(details[0].orders.orderDate).toLocaleString()}</td>
            </tr>
            <tr>
              <th scope="col">Order Id</th>
              <td>{details[0].orders.orderId}</td>
            </tr>
            <tr>
              <th scope="col">Total Bill</th>
              <td>₹ {details[0].orders.totalBill}</td>
            </tr>
            <tr>
              <th scope="col">Payment Id</th>
              <td>{details[0].orders.paymentId}</td>
            </tr>
          </tbody>
        </table>
        <h4>Product Details</h4>
        <table className="table">
          <thead>
            <tr>
              <th scope="col">Name</th>
              <th scope="col">Price</th>
              <th scope="col">Quantity</th>
            </tr>
          </thead>
          <tbody>
            { details &&
                details.map(ordrdetail => 
                     <tr key={ordrdetail.id}>
                        <td scope="row">{ordrdetail.product.name}</td>
                        <td>{ordrdetail.product.price}</td>
                        <td>{ordrdetail.quantity}</td>
                    </tr>
                )
            }
          </tbody>
        </table>
        <button className="btn btn-primary" onClick={() => navigate("/myorders")}>
          Back
        </button>
      </div>
    </div>
  );
  
}
