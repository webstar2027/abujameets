require('dotenv').config();
const express=require('express'),path=require('path');
const app=express(),PORT=process.env.PORT||3000;
app.use(express.json({limit:'1mb'}));app.use(express.static(path.join(__dirname,'public')));
app.get('/api/health',(_q,r)=>r.json({ok:true,site:'Abuja Meet',databaseConfigured:Boolean(process.env.SUPABASE_URL&&process.env.SUPABASE_SERVICE_ROLE_KEY)}));
app.get('/api/config',(_q,r)=>r.json({plans:[{id:'month',amountNaira:3000,days:30},{id:'two_months',amountNaira:5000,days:60},{id:'three_months',amountNaira:8000,days:90}],locations:['FCT','Lagos','Nasarawa'],providers:['paystack','flutterwave']}));
app.post('/api/payments/initialize',(_q,r)=>r.status(503).json({error:'Secure payment checkout is not enabled yet. Do not send money until payment verification is implemented.'}));
app.get('*',(_q,r)=>r.sendFile(path.join(__dirname,'public','index.html')));app.listen(PORT,'0.0.0.0',()=>console.log('Abuja Meet listening on '+PORT));
