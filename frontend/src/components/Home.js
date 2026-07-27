import React, { useEffect, useState } from 'react'
import Product from './Product';

export default function Home() {
  // const BASE_URL = process.env.REACT_APP_API_URL;
  // console.log(BASE_URL);
  
  const [allProducts, setAllProducts] = useState(null);
  const [allCategories, setAllCategories] = useState(null);
  const [selectedCategory, setSelectedCategory] = useState(null);
  const [name, setName] = useState(null)
  const [maxPrice, setMaxPrice] = useState(null);
  const [direction, setDirection] = useState("asc");

  useEffect(()=>{
    fetch(`${process.env.REACT_APP_API_URL}/api/categories`)
    .then(resp => resp.json())
    .then(data=> setAllCategories(data));
 },[]);

  useEffect(()=>{
    searchProducts();
  },[direction]);

  function searchProducts(){
    const params = new URLSearchParams();
    if(selectedCategory){
      params.append("category",selectedCategory);
    }
    if(name){
      params.append("name",name);
    }
    if(maxPrice){
      params.append("maxPrice",maxPrice);
    }
    if(direction){
      params.append("direction",direction);
    }
   
    fetch(`${process.env.REACT_APP_API_URL}/api/search-products?${params.toString()}`)
    .then(resp => resp.json())
    .then(data => setAllProducts(data))
  }
  
  return (
    <>      
      <div className='row mt-2'>
        { allCategories &&
        <div className='col-2'>
          <select className="form-control" name="category" onChange={(event)=>setSelectedCategory(event.target.value)}>
            <option value="">All</option>
           {
            allCategories.map(cat => <option key={cat} value={cat}>{cat}</option>)
           }
          </select>
        </div>
        }
        <div className='col-md-2'>
          <input type="text" placeholder="plz enter any name to search" 
          className=' form-control' onChange={(event)=>setName(event.target.value)}
           />
        </div>
        <div className='col-md-2'>
          <input type="text" placeholder="plz enter maximum price" 
          className=' form-control' onChange={(event)=>setMaxPrice(event.target.value)}
           />
        </div>
        <div className='col-md-2'>
         <button className='btn btn-link ' 
         onClick={()=>setDirection(direction=="asc"?"desc":"asc")}>
          {direction=="asc"?"High To Low":"Low to high"}
         </button>        
        </div>
        <button className=' col-1 btn btn-primary' onClick={searchProducts}>Search</button>
      </div>
      <div className='row mt-3'>
        {
        allProducts && allProducts.map( prod => <Product key={prod.id} prod={prod}/> )
        }
      </div>
    </>
  )
}
