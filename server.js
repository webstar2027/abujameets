require('dotenv').config();
const express=require('express'),path=require('path');
const app=express(),PORT=process.env.PORT||3000;
app.use(express.json());app.use(express.static(path.join(__dirname,'public')));
app.get('/api/health',(_req,res)=>res.json({ok:true,site:'Abuja Meets',databaseConfigured:Boolean(process.env.SUPABASE_URL&&process.env.SUPABASE_SERVICE_ROLE_KEY)}));
app.get('/api/locations',(_req,res)=>res.json({locations:{FCT:['Abuja','Gwarinpa','Kubwa','Wuse','Garki','Maitama'],Lagos:['Ikeja','Lekki','Victoria Island','Surulere','Yaba'],Nasarawa:['Keffi','Mararaba','Karu','Lafia','Akwanga']}}));
app.post('/api/payments/initialize',(_req,res)=>res.status(501).json({error:'Secure Paystack/Flutterwave checkout is not implemented yet. Do not collect payments until provider verification is configured.'}));
app.get('*',(_req,res)=>res.sendFile(path.join(__dirname,'public','index.html')));
app.listen(PORT,'0.0.0.0',()=>console.log(`Abuja Meets listening on ${PORT}`));
