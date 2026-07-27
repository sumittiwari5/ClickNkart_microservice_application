import React from 'react'
import { NavLink } from 'react-router-dom';

export default function Navbar() {
    const token = localStorage.getItem("jwtToken");
    // console.log("navbar:", token);
    const roles = localStorage.getItem("roles");
    // string 'ROLE_ADMIN,ROLE_USER]'

    function doLogout() {
        localStorage.clear();
        window.location.href = "/";
    }

    return (
        <div>
            <nav className="navbar navbar-expand-lg bg-dark" data-bs-theme="dark">
                <div className="container-fluid">
                    <a className="navbar-brand" href="#">ClickNCart</a>
                    <button className="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                        <span className="navbar-toggler-icon"></span>
                    </button>
                    <div className="collapse navbar-collapse" id="navbarSupportedContent">
                        <ul className="navbar-nav me-auto mb-2 mb-lg-0">
                            <li className="nav-item">
                                <NavLink className="nav-link " aria-current="page" to={"/"}>Home</NavLink>
                            </li>
                            {
                                !token &&
                                <>
                                    <li className="nav-item">
                                        <NavLink className="nav-link" to={"/login"}>Login</NavLink>
                                    </li>
                                    <li className="nav-item">
                                        <NavLink className="nav-link" to={"/register"}>Register</NavLink>
                                    </li>
                                </>
                            }
                            {
                               roles && roles.includes("USER") &&
                                <>
                                    <li className="nav-item">
                                        <NavLink className="nav-link " aria-current="page" to={"/mycart"}>My Cart</NavLink>
                                    </li>
                                    <li className="nav-item">
                                        <NavLink className="nav-link " aria-current="page"
                                        to={'/myorders'}>My Orders</NavLink>
                                    </li>
                                </>
                            }
                            {
                                roles && roles.includes("ADMIN") &&
                                <>
                                    <li className="nav-item">
                                        <NavLink className="nav-link " aria-current="page" to={'/add-product'}>Add Product</NavLink>
                                    </li>
                                    {/* <li className="nav-item">
                                        <NavLink className="nav-link " aria-current="page">Users</NavLink>
                                    </li> */}
                                </>
                            }
                            {
                                token &&
                                <>
                                
                                    <li className="nav-item">
                                        <button className="nav-link" 
                                        onClick={doLogout}>Logout</button>
                                    </li>
                                </>
                            }
                            {/* <li className="nav-item dropdown">
                                <a className="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    Dropdown
                                </a>
                                <ul className="dropdown-menu">
                                    <li><a className="dropdown-item" href="#">Action</a></li>
                                    <li><a className="dropdown-item" href="#">Another action</a></li>
                                    <li><hr className="dropdown-divider" /></li>
                                    <li><a className="dropdown-item" href="#">Something else here</a></li>
                                </ul>
                            </li>
                            <li className="nav-item">
                                <a className="nav-link disabled" aria-disabled="true">Disabled</a>
                            </li> */}
                        </ul>
                        {/* <form className="d-flex" role="search">
                            <input className="form-control me-2" type="search" placeholder="Search" aria-label="Search" />
                            <button className="btn btn-outline-success" type="submit">Search</button>
                        </form> */}
                    </div>
                </div>
            </nav>
        </div>
    )
}
