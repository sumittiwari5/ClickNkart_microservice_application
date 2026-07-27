import React from 'react';
import {NavLink} from 'react-router-dom'; 

export default function Product(props) {
    const product = props.prod;

    return (
        <div className='col-md-3 mt-2 '>
            <div className="card" style={{ "width": "100%" }}>
                <img src={product.imageUrl} className="card-img-top" alt="..." />
                <div className="card-body">
                    <h5 className="card-title">Name: {product.name}</h5>
                    <h5>Category: {product.category}</h5>
                    <p className="card-text">{product.description.substring(0,50)}...</p>
                    <h4>Price ₹. {product.price}</h4>
                    <NavLink 
                    to={`/details/${product.id}`} className="btn btn-primary">Details</NavLink>
                </div>
            </div>
        </div>
    )
}
