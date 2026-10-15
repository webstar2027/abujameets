const $ = id => document.getElementById(id);
$('year').textContent = new Date().getFullYear();
let mode = 'signup', supabase = null, configError = '';
const modal = $('modal');
function setMessage(text, kind='') { $('message').textContent = text; $('message').className = 'message' + (kind ? ' ' + kind : ''); }
function openAuth(m='signup') {
  mode=m;
  $('modalTitle').textContent=m==='signup'?'Create your free account':'Welcome back';
  $('submit').textContent=m==='signup'?'Create free account':'Log in';
  ['displayName','accountType','profession','state'].forEach(id=>{const field=$(id);field.style.display=m==='signup'?'':'none';if(field.previousElementSibling)field.previousElementSibling.style.display=m==='signup'?'':'none';});
  $('switchPrompt').textContent=m==='signup'?'Already registered?':'New to Abuja Meet?';
  $('switch').textContent=m==='signup'?'Log in':'Create account';
  setMessage(configError || ''); modal.classList.remove('hidden'); document.body.style.overflow='hidden';
}
function close(){modal.classList.add('hidden');document.body.style.overflow='';}
$('join').onclick=$('heroJoin').onclick=$('bottomJoin').onclick=()=>openAuth('signup');
$('login').onclick=()=>openAuth('login'); $('close').onclick=close;
modal.addEventListener('click',e=>{if(e.target===modal)close()});
document.addEventListener('keydown',e=>{if(e.key==='Escape')close()});
$('switch').onclick=()=>openAuth(mode==='signup'?'login':'signup');
$('showPw').onclick=()=>{const p=$('password');p.type=p.type==='password'?'text':'password';$('showPw').textContent=p.type==='password'?'Show':'Hide'};
document.querySelectorAll('.location').forEach(b=>b.onclick=()=>{document.querySelectorAll('.location').forEach(x=>x.classList.remove('active'));b.classList.add('active');$('state').value=b.dataset.state});
document.querySelectorAll('.plan').forEach(b=>b.onclick=()=>{openAuth('signup');setMessage('Selected '+({'month':'₦3,000 for 1 month','two_months':'₦5,000 for 2 months','three_months':'₦8,000 for 3 months'}[b.dataset.plan])+'. You can create an account now; secure payment checkout is not enabled yet.')});
async function init(){
  try {
    const r=await fetch('/api/config'); const c=await r.json();
    if(!window.supabase || !c.supabaseUrl || !c.supabaseAnonKey){configError='Account service is not configured yet. The site owner must add SUPABASE_URL and SUPABASE_ANON_KEY in Render.';return;}
    supabase=window.supabase.createClient(c.supabaseUrl,c.supabaseAnonKey);
  } catch(e){configError='Could not connect to the account service. Please try again later.';}
}
$('form').onsubmit=async e=>{
  e.preventDefault();
  if(!supabase){setMessage(configError || 'Account service is not ready.');return;}
  const email=$('email').value.trim(), password=$('password').value;
  const btn=$('submit');btn.disabled=true;btn.textContent=mode==='signup'?'Creating account…':'Logging in…';setMessage('');
  try {
    let result;
    if(mode==='signup'){
      const displayName=$('displayName').value.trim(), accountType=$('accountType').value, profession=$('profession').value, state=$('state').value;
      if(!displayName){throw new Error('Please enter your name.');}
      if(!profession){throw new Error('Please choose your profession.');}
      result=await supabase.auth.signUp({email,password,options:{data:{display_name:displayName,account_type:accountType,profession,state},emailRedirectTo:location.origin}});
      if(result.error) throw result.error;
      if(result.data.session){setMessage('Account created successfully. You are now signed in.','success');setTimeout(()=>{close();location.reload()},900);}
      else setMessage('Registration received. Check your email for a confirmation link, then return here and log in.','success');
    } else {
      result=await supabase.auth.signInWithPassword({email,password});
      if(result.error) throw result.error;
      setMessage('Login successful. Opening your account…','success');setTimeout(()=>{close();location.reload()},700);
    }
  } catch(err){setMessage(err.message || 'Something went wrong. Please try again.','error');}
  finally{btn.disabled=false;btn.textContent=mode==='signup'?'Create free account':'Log in';}
};
init();
