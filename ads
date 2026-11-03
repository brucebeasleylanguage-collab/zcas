<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
  <title>Tiệm Bánh Chuối Poinhoinhoi 3D 360° — Vạn Giới Bá Chủ</title>

  <script src="https://cdn.tailwindcss.com"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;800;900&display=swap" rel="stylesheet">

  <style>
    * { box-sizing:border-box; -webkit-tap-highlight-color:transparent; font-family:Outfit,system-ui,sans-serif; }
    html,body { margin:0;width:100%;height:100%;overflow:hidden;background:#05070f;color:#fff; }
    #canvas-container { position:fixed;inset:0;z-index:0;touch-action:none; }
    #canvas-container canvas { display:block; }
    .glass {
      background:rgba(13,18,32,.78);backdrop-filter:blur(14px);
      border:1px solid rgba(255,255,255,.13);box-shadow:0 12px 35px #0005;
    }
    .btn { border:1px solid #ffffff20;background:#1e293bbd;border-radius:12px;padding:.55rem .8rem;transition:.18s; }
    .btn:hover { background:#334155;transform:translateY(-1px); }
    .btn:active { transform:scale(.97); }
    .pink { background:linear-gradient(120deg,#ec4899,#f43f5e,#f59e0b); }
    #toast { opacity:0;transition:opacity .25s;pointer-events:none; }
    #toast.show { opacity:1; }
    .meter { height:8px;background:#1e293b;border-radius:9px;overflow:hidden; }
    .meter i { display:block;height:100%;background:linear-gradient(90deg,#22d3ee,#a855f7,#f472b6); }
    @media(max-width:700px) {
      .desktop-only { display:none!important; }
      #bottom { padding-bottom:max(8px,env(safe-area-inset-bottom)); }
    }
  </style>
</head>
<body>
  <div id="canvas-container"></div>

  <main class="fixed inset-0 z-10 p-3 md:p-5 flex flex-col justify-between pointer-events-none">
    <header class="flex justify-between items-start gap-2">
      <div class="glass rounded-2xl p-3 pointer-events-auto">
        <div class="font-black text-sm md:text-lg text-pink-200">🐰 POINHOINHOI 3D BAKERY</div>
        <div class="text-[10px] text-slate-300">Vạn Giới Bá Chủ · Kéo để xoay 360°</div>
      </div>

      <div class="flex flex-wrap justify-end gap-2 pointer-events-auto">
        <div class="glass rounded-xl px-3 py-2 text-xs md:text-sm">🪙 <b id="money">150</b></div>
        <div class="glass rounded-xl px-3 py-2 text-xs md:text-sm">💎 <b id="gems">5</b></div>
        <div class="glass rounded-xl px-3 py-2 text-xs md:text-sm">🍌 <b id="cakes">0</b></div>
        <button id="imageButton" class="btn text-xs" title="Chọn ảnh nhân vật">🖼️ Ảnh</button>
        <input id="imageInput" type="file" accept="image/*" hidden>
        <button id="soundButton" class="btn text-xs" title="Bật/tắt âm thanh">🔊</button>
        <button id="photoButton" class="btn text-xs" title="Chụp ảnh">📸</button>
      </div>
    </header>

    <section class="glass rounded-2xl p-3 w-full max-w-[360px] pointer-events-auto">
      <div class="flex justify-between items-center">
        <b class="text-pink-200">🌦️ Thời tiết</b>
        <button id="weatherButton" class="btn text-xs">Đổi thời tiết</button>
      </div>
      <div id="weatherName" class="text-sm mt-1">☀️ Nắng Kim Đan</div>
      <div id="weatherDesc" class="text-[10px] text-slate-300 mt-1">Nắng vàng và giá bánh tăng.</div>

      <div class="mt-3 flex justify-between text-xs">
        <span>🔥 Mẻ bánh</span><b id="bakeStatus">Sẵn sàng</b>
      </div>
      <div class="meter mt-1"><i id="bakeMeter" style="width:0%"></i></div>

      <div class="grid grid-cols-2 gap-2 mt-3">
        <button id="bakeButton" class="btn pink font-black text-sm">🍌 Làm bánh · 10 xu</button>
        <button id="sellButton" class="btn text-emerald-300 font-bold text-sm">🛎️ Bán bánh</button>
      </div>

      <div class="grid grid-cols-3 gap-2 mt-2">
        <button id="cultivateButton" class="btn text-xs">✨ Tu luyện</button>
        <button id="upgradeButton" class="btn text-xs">⬆ Nâng tiệm</button>
        <button id="auraButton" class="btn text-xs">🌈 Đổi Aura</button>
      </div>
      <div class="meter mt-2"><i id="cultivateMeter" style="width:0%"></i></div>
      <div class="flex justify-between text-[10px] text-slate-300 mt-1">
        <span id="realmName">Cảnh giới: Luyện Khí</span><span id="cultivateText">0/100</span>
      </div>
      <div id="eventName" class="text-[10px] text-amber-200 mt-2">Sự kiện: Chưa bắt đầu</div>
    </section>

    <footer id="bottom" class="flex justify-center">
      <div id="toast" class="glass rounded-full px-4 py-2 text-sm text-pink-100">Sẵn sàng!</div>
    </footer>
  </main>

  <script>
  (() => {
    'use strict';

    const $ = id => document.getElementById(id);
    const SAVE_KEY = 'poinhoinhoi_complete_game_v1';
    const IMAGE_KEY = 'poinhoinhoi_character_image_v1';

    const WEATHER = [
      { id:'sakura', name:'🌸 Mưa Hoa Đào', desc:'Cánh hoa hồng phấn bay nhẹ nhàng.', color:0xff9ecb, bg:0x160b1c },
      { id:'snow', name:'❄️ Tuyết Rơi Linh Khí', desc:'Tuyết trắng lấp lánh trong không gian.', color:0xd9f4ff, bg:0x091326 },
      { id:'storm', name:'⚡ Bão Sấm Sét', desc:'Mây giông và chớp sáng bất chợt.', color:0x8db8ff, bg:0x080a17 },
      { id:'starfall', name:'🌠 Mưa Sao Băng', desc:'Tăng mạnh cơ hội bánh Perfect.', color:0xffeda0, bg:0x050817 },
      { id:'bloodmoon', name:'🩸 Huyết Nguyệt', desc:'Ánh trăng đỏ ma quái.', color:0xff526a, bg:0x190811 },
      { id:'sun', name:'☀️ Nắng Kim Đan', desc:'Nắng vàng rực rỡ, giá bánh tăng.', color:0xffd166, bg:0x111126 }
    ];

    const CUSTOMER_TYPES = [
      { name:'Robot Cyberpunk', emoji:'🤖', color:0x14b8a6, crop:'robot' },
      { name:'Tiên tử ngự kiếm', emoji:'🧚', color:0xd8b4fe, crop:'fairy' },
      { name:'Ma thần cưỡi mây', emoji:'👹', color:0x991b1b, crop:'demon' },
      { name:'Michael Jackson', emoji:'🕺', color:0x171717, crop:'mj', special:true }
    ];
    const REALMS = ['Luyện Khí','Trúc Cơ','Kim Đan','Nguyên Anh','Hóa Thần','Vô Thượng'];
    const AURAS = [
      { name:'Tắt', color:0xffffff },
      { name:'Long Phụng Cửu Thiên', color:0xffc857 },
      { name:'Ma Thần Tử Khí', color:0xa855f7 },
      { name:'Rainbow Neon', color:0x22d3ee },
      { name:'Vô Cực Nebula', color:0x7dd3fc }
    ];

    let state = {
      money:150, gems:5, cakes:0, served:0, realm:0, cultivation:0,
      shopLevel:1, aura:0, sound:true, weather:5, day:1, bestScore:0
    };
    try {
      const saved = JSON.parse(localStorage.getItem(SAVE_KEY) || '{}');
      state = { ...state, ...saved };
    } catch (e) {}

    let scene, camera, renderer, controls, clock, shopGroup, poyo, poyoBody;
    let weatherPoints, weatherGeo, weatherMoon, lightning;
    let auraGroup, customers = [], imageSource = null;
    let baking = false, bakeProgress = 0, eventTimer = 18, activeEvent = '';
    let spawnClock = 0, gameClock = 0, toastTimer = 0, audioContext = null;
    let auraIndex = Number(state.aura) || 0;

    function save() {
      try {
        state.aura = auraIndex;
        localStorage.setItem(SAVE_KEY, JSON.stringify(state));
      } catch (e) {}
    }

    function notify(text) {
      $('toast').textContent = text;
      $('toast').classList.add('show');
      clearTimeout(toastTimer);
      toastTimer = setTimeout(() => $('toast').classList.remove('show'), 2600);
    }

    function sound(frequency=700, duration=.12, wave='sine') {
      if (!state.sound) return;
      try {
        audioContext ||= new (window.AudioContext || window.webkitAudioContext)();
        if (audioContext.state === 'suspended') audioContext.resume();
        const osc = audioContext.createOscillator();
        const gain = audioContext.createGain();
        osc.type = wave;
        osc.frequency.value = frequency;
        gain.gain.setValueAtTime(.0001, audioContext.currentTime);
        gain.gain.exponentialRampToValueAtTime(.11, audioContext.currentTime + .015);
        gain.gain.exponentialRampToValueAtTime(.0001, audioContext.currentTime + duration);
        osc.connect(gain); gain.connect(audioContext.destination);
        osc.start(); osc.stop(audioContext.currentTime + duration);
      } catch (e) {}
    }

    function updateHUD() {
      $('money').textContent = Math.floor(state.money).toLocaleString('vi-VN');
      $('gems').textContent = state.gems;
      $('cakes').textContent = state.cakes;
      $('realmName').textContent = 'Cảnh giới: ' + REALMS[state.realm];
      $('cultivateText').textContent = state.cultivation + '/100';
      $('cultivateMeter').style.width = state.cultivation + '%';
      $('weatherName').textContent = WEATHER[state.weather].name;
      $('weatherDesc').textContent = WEATHER[state.weather].desc;
    }

    const material = (color, roughness=.7, emissive=0) =>
      new THREE.MeshStandardMaterial({ color, roughness, emissive, emissiveIntensity: emissive ? .8 : 0 });

    function box(parent, x,y,z, sx,sy,sz, mat) {
      const mesh = new THREE.Mesh(new THREE.BoxGeometry(sx,sy,sz), mat);
      mesh.position.set(x,y,z);
      mesh.castShadow = true;
      mesh.receiveShadow = true;
      parent.add(mesh);
      return mesh;
    }

    function sphere(parent,x,y,z,r,mat,sx=1,sy=1,sz=1) {
      const mesh = new THREE.Mesh(new THREE.SphereGeometry(r,20,16),mat);
      mesh.position.set(x,y,z);
      mesh.scale.set(sx,sy,sz);
      mesh.castShadow = true;
      parent.add(mesh);
      return mesh;
    }

    function init3D() {
      const host = $('canvas-container');
      scene = new THREE.Scene();
      scene.background = new THREE.Color(WEATHER[state.weather].bg);
      scene.fog = new THREE.Fog(WEATHER[state.weather].bg, 12, 38);

      camera = new THREE.PerspectiveCamera(48, innerWidth/innerHeight, .1, 100);
      camera.position.set(0, 4.3, 10.5);

      renderer = new THREE.WebGLRenderer({ antialias:true, preserveDrawingBuffer:true });
      renderer.setPixelRatio(Math.min(devicePixelRatio || 1, 2));
      renderer.setSize(innerWidth, innerHeight);
      renderer.shadowMap.enabled = true;
      renderer.shadowMap.type = THREE.PCFSoftShadowMap;
      if (THREE.sRGBEncoding) renderer.outputEncoding = THREE.sRGBEncoding;
      host.appendChild(renderer.domElement);

      if (THREE.OrbitControls) {
        controls = new THREE.OrbitControls(camera, renderer.domElement);
        controls.enableDamping = true;
        controls.dampingFactor = .06;
        controls.enablePan = false;
        controls.minDistance = 5;
        controls.maxDistance = 17;
        controls.maxPolarAngle = Math.PI / 2.03;
        controls.target.set(0,1.3,0);
      }

      clock = new THREE.Clock();
      scene.add(new THREE.HemisphereLight(0xc9d5ff,0x382849,1.7));

      const sun = new THREE.DirectionalLight(0xffedc4,2.4);
      sun.position.set(-5,10,7);
      sun.castShadow = true;
      scene.add(sun);
      scene.userData.sun = sun;

      const pinkLight = new THREE.PointLight(0xf472b6,12,16);
      pinkLight.position.set(-4,3,2);
      scene.add(pinkLight);
      const cyanLight = new THREE.PointLight(0x22d3ee,12,16);
      cyanLight.position.set(4,3,-2);
      scene.add(cyanLight);

      buildWorld();
      buildPoyo();
      buildWeather();
      auraGroup = new THREE.Group();
      scene.add(auraGroup);
      applyWeather();
      updateHUD();
      window.addEventListener('resize', resize);
      animate();
    }

    function buildWorld() {
      const floor = new THREE.Mesh(new THREE.PlaneGeometry(80,80),material(0x111327));
      floor.rotation.x = -Math.PI/2;
      floor.position.y = -.04;
      floor.receiveShadow = true;
      scene.add(floor);
      const grid = new THREE.GridHelper(80,48,0x513b80,0x282640);
      grid.position.y = 0;
      scene.add(grid);

      shopGroup = new THREE.Group();
      scene.add(shopGroup);
      const wood = material(0x70422d);
      const trim = material(0xf6c66b,.32,0x543000);
      const roof = material(0x342449,.48,0x211038);

      box(shopGroup,0,1.05,0,5.2,2.1,2.2,wood);
      box(shopGroup,0,2.2,0,5.6,.24,2.55,roof);
      box(shopGroup,0,2.38,0,4.7,.1,2.2,trim);
      box(shopGroup,0,1.78,1.16,5.4,.15,.3,trim);
      box(shopGroup,0,2.9,-.15,3,.72,.2,roof);
      box(shopGroup,0,2.9,.05,2.5,.4,.06,material(0x7724a8,.35,0x6a22ff));
      box(shopGroup,0,.62,1.45,2.4,.85,.66,
        new THREE.MeshPhysicalMaterial({color:0xb8e6ff,transparent:true,opacity:.22,roughness:.08}));
      for (let i=0;i<5;i++) {
        const cake=sphere(shopGroup,-.82+i*.41,.69,1.42,.17,material(0xffd166,.35,0x5c3000),1.2,.65,1);
        cake.scale.set(1.2,.65,1);
      }

      const signLight = new THREE.PointLight(0xf0abfc,10,9);
      signLight.position.set(0,3.2,1.2);
      scene.add(signLight);
    }

    function buildPoyo() {
      poyo = new THREE.Group();
      poyo.position.set(-2.2,0,2.35);
      scene.add(poyo);

      const bodyMat = new THREE.MeshPhysicalMaterial({
        color:0xffd9d4, roughness:.2, clearcoat:1, clearcoatRoughness:.1
      });
      poyoBody = sphere(poyo,0,.82,0,.73,bodyMat,1,1,.84);

      for (const x of [-.25,.25]) {
        sphere(poyo,x,.95,.58,.14,material(0xffffff),1,1,.4);
        sphere(poyo,x,.95,.64,.085,material(0x211c28),1,1,.4);
        sphere(poyo,x-.03,.99,.68,.025,material(0xffffff),1,1,.5);
      }
      sphere(poyo,-.43,.68,.44,.105,material(0xff9cae),1,.6,.35);
      sphere(poyo,.43,.68,.44,.105,material(0xff9cae),1,.6,.35);

      const ring = new THREE.Mesh(new THREE.TorusGeometry(.92,.032,8,64),
        new THREE.MeshBasicMaterial({color:0x62eaff}));
      ring.position.y=.9;
      ring.rotation.x=Math.PI/2.5;
      poyo.add(ring);

      const ring2 = new THREE.Mesh(new THREE.TorusGeometry(1.02,.022,8,64),
        new THREE.MeshBasicMaterial({color:0xff69c8}));
      ring2.rotation.set(.85,0,.35);
      poyo.add(ring2);
    }

    function buildWeather() {
      const count = 620;
      const positions = new Float32Array(count*3);
      for (let i=0;i<count;i++) {
        positions[i*3] = Math.random()*24-12;
        positions[i*3+1] = Math.random()*14;
        positions[i*3+2] = Math.random()*22-14;
      }
      weatherGeo = new THREE.BufferGeometry();
      weatherGeo.setAttribute('position',new THREE.BufferAttribute(positions,3));
      const textureCanvas=document.createElement('canvas');
      textureCanvas.width=textureCanvas.height=64;
      const ctx=textureCanvas.getContext('2d');
      const grad=ctx.createRadialGradient(32,32,1,32,32,31);
      grad.addColorStop(0,'rgba(255,255,255,1)');
      grad.addColorStop(.28,'rgba(255,255,255,.85)');
      grad.addColorStop(1,'rgba(255,255,255,0)');
      ctx.fillStyle=grad;ctx.fillRect(0,0,64,64);

      weatherPoints = new THREE.Points(weatherGeo,new THREE.PointsMaterial({
        map:new THREE.CanvasTexture(textureCanvas),
        color:0xffc4df,size:.16,transparent:true,opacity:.85,
        depthWrite:false,blending:THREE.AdditiveBlending
      }));
      weatherPoints.frustumCulled=false;
      scene.add(weatherPoints);

      weatherMoon = new THREE.Mesh(new THREE.SphereGeometry(1.12,24,20),
        new THREE.MeshBasicMaterial({color:0xc81e45}));
      weatherMoon.position.set(-7,7,-12);
      scene.add(weatherMoon);

      lightning = new THREE.PointLight(0xb9c7ff,0,38);
      lightning.position.set(1,8,-2);
      scene.add(lightning);
    }

    function applyWeather() {
      const w=WEATHER[state.weather];
      scene.background.setHex(w.bg);
      scene.fog.color.setHex(w.bg);
      weatherPoints.material.color.setHex(w.color);
      weatherMoon.visible=state.weather===4;
      scene.userData.sun.intensity=state.weather===5?2.8:state.weather===2?.95:2.1;
      if (state.weather===2) lightning.intensity=0;
      $('weatherName').textContent=w.name;
      $('weatherDesc').textContent=w.desc;
    }

    function createCharacter(type) {
      const group = new THREE.Group();
      const bodyMat = material(type.color,.45,type.special?0x000000:0);
      const dark = material(type.special?0x101014:0x20243a);
      const skin = material(0xf0c6a5);
      const glowing = material(type.special?0xffffff:0x18e8ff,.3,type.special?0xbababa:0x087d99);

      // Dáng nhân vật 3D cơ bản; ảnh tham khảo được ghép thành sprite phía trước.
      const body=box(group,0,.77,0,.58,.78,.32,bodyMat);
      sphere(group,0,1.42,0,.28,skin);
      box(group,-.18,.25,0,.19,.48,.21,dark);
      box(group,.18,.25,0,.19,.48,.21,dark);
      box(group,-.36,.88,0,.18,.62,.2,dark);
      box(group,.36,.88,0,.18,.62,.2,dark);

      if (type.special) {
        const brim=new THREE.Mesh(new THREE.CylinderGeometry(.34,.34,.045,20),dark);
        brim.position.y=1.72;group.add(brim);
        const hat=new THREE.Mesh(new THREE.CylinderGeometry(.22,.25,.23,18),dark);
        hat.position.y=1.85;group.add(hat);
        sphere(group,-.48,.93,.04,.12,glowing);
        sphere(group,.48,.93,.04,.12,glowing);
        body.rotation.y=.08;
      } else if (type.crop==='robot') {
        box(group,0,1.43,.23,.38,.16,.08,glowing);
        box(group,-.12,1.43,.28,.055,.04,.025,material(0x33f4ff,.2,0x15c7ff));
        box(group,.12,1.43,.28,.055,.04,.025,material(0x33f4ff,.2,0x15c7ff));
      } else if (type.crop==='demon') {
        for(const s of [-1,1]) {
          const horn=new THREE.Mesh(new THREE.ConeGeometry(.08,.38,10),material(0x9f5cff,.3,0x5715a8));
          horn.position.set(s*.16,1.76,0);horn.rotation.z=-s*.32;group.add(horn);
        }
      } else {
        for(const s of [-1,1]) {
          const wing=new THREE.Mesh(new THREE.SphereGeometry(.3,12,10),
            new THREE.MeshBasicMaterial({color:0xf9ddff,transparent:true,opacity:.72}));
          wing.position.set(s*.37,1.47,-.15);wing.scale.set(.55,1.5,.18);group.add(wing);
        }
      }
      group.traverse(o=>{if(o.isMesh){o.castShadow=true;o.receiveShadow=true;}});
      return group;
    }

    // Vùng cắt được căn theo ảnh tham khảo 832×832 có nền đen.
    const CROPS = {
      robot:{x:.045,y:.425,w:.18,h:.24},
      mj:{x:.125,y:.285,w:.28,h:.38},
      fairy:{x:.515,y:.385,w:.21,h:.285},
      demon:{x:.715,y:.30,w:.235,h:.39}
    };

    function attachReferenceImage(customer) {
      if (!imageSource || !customer || !customer.mesh) return;
      const crop=CROPS[customer.type.crop]||CROPS.robot;
      const canvas=document.createElement('canvas');
      canvas.width=256;canvas.height=360;
      const ctx=canvas.getContext('2d',{willReadFrequently:true});
      const sx=Math.floor(imageSource.width*crop.x);
      const sy=Math.floor(imageSource.height*crop.y);
      const sw=Math.max(1,Math.floor(imageSource.width*crop.w));
      const sh=Math.max(1,Math.floor(imageSource.height*crop.h));

      ctx.clearRect(0,0,canvas.width,canvas.height);
      ctx.drawImage(imageSource,sx,sy,sw,sh,0,0,canvas.width,canvas.height);

      // Xóa nền đen ảnh tham khảo và làm viền mượt hơn.
      const pixels=ctx.getImageData(0,0,canvas.width,canvas.height);
      for(let i=0;i<pixels.data.length;i+=4) {
        const brightness=(pixels.data[i]+pixels.data[i+1]+pixels.data[i+2])/3;
        if(brightness<14) pixels.data[i+3]=0;
        else if(brightness<32) pixels.data[i+3]=Math.round(pixels.data[i+3]*(brightness-14)/18);
      }
      ctx.putImageData(pixels,0,0);

      const tex=new THREE.CanvasTexture(canvas);
      if(THREE.sRGBEncoding) tex.encoding=THREE.sRGBEncoding;
      const sprite=new THREE.Sprite(new THREE.SpriteMaterial({
        map:tex,transparent:true,depthWrite:false,alphaTest:.025
      }));
      sprite.position.set(0,1.05,.205);
      sprite.scale.set(1.42,2.0,1);
      customer.mesh.add(sprite);
      customer.sprite=sprite;
    }

    function addCustomer(type=null) {
      if(customers.length>=5) return;
      type=type||CUSTOMER_TYPES[Math.floor(Math.random()*CUSTOMER_TYPES.length)];
      const mesh=createCharacter(type);
      mesh.position.set((Math.random()-.5)*5,0,-5.8);
      mesh.rotation.y=Math.PI;
      scene.add(mesh);
      const c={mesh,type,phase:Math.random()*6,state:'arrive',wait:0};
      customers.push(c);
      attachReferenceImage(c);
      return c;
    }

    function setImage(file) {
      if(!file || !file.type.startsWith('image/')) {
        notify('Hãy chọn ảnh PNG, JPG hoặc WebP.');
        return;
      }
      const reader=new FileReader();
      reader.onload=()=>{
        const img=new Image();
        img.onload=()=>{
          imageSource=img;
          try { localStorage.setItem(IMAGE_KEY,reader.result); }
          catch(e) { notify('Ảnh quá lớn để lưu; ảnh vẫn dùng được trong phiên này.'); }
          customers.forEach(attachReferenceImage);
          notify('🖼️ Đã ghép ảnh tham khảo lên nhân vật!');
        };
        img.onerror=()=>notify('Không đọc được ảnh này.');
        img.src=reader.result;
      };
      reader.onerror=()=>notify('Không thể tải tệp ảnh.');
      reader.readAsDataURL(file);
    }

    function updateAura(t) {
      if(!auraGroup) return;
      while(auraGroup.children.length) {
        const obj=auraGroup.children.pop();
        if(obj.parent) obj.parent.remove(obj);
      }
      if(auraIndex===0) return;

      const cfg=AURAS[auraIndex];
      for(let i=0;i<7;i++) {
        const a=t*1.1+i*Math.PI*2/7;
        const color=auraIndex===3 ? new THREE.Color().setHSL((t*.12+i/7)%1,1,.62) : new THREE.Color(cfg.color);
        const orb=new THREE.Mesh(new THREE.SphereGeometry(.075,10,8),
          new THREE.MeshBasicMaterial({color}));
        orb.position.set(-2.2+Math.cos(a)*1.12,1.1+Math.sin(a*1.7)*.55,2.35+Math.sin(a)*.95);
        auraGroup.add(orb);
      }
      const ring=new THREE.Mesh(new THREE.TorusGeometry(1.18,.035,8,60),
        new THREE.MeshBasicMaterial({color:auraIndex===3?0xff5fe2:cfg.color}));
      ring.position.set(-2.2,1.05,2.35);
      ring.rotation.x=Math.PI/2;
      ring.rotation.z=t*.6;
      auraGroup.add(ring);
    }

    function updateWeather(dt,t) {
      if(!weatherPoints) return;
      const id=WEATHER[state.weather].id;
      const visible=['sakura','snow','storm','starfall','bloodmoon'].includes(id);
      weatherPoints.visible=visible;

      const mat=weatherPoints.material;
      let speed=.7, size=.15;
      if(id==='sakura'){speed=1.1;size=.2;mat.opacity=.86;}
      if(id==='snow'){speed=1.8;size=.14;mat.opacity=.9;}
      if(id==='storm'){speed=4.2;size=.11;mat.opacity=.55;}
      if(id==='starfall'){speed=7.8;size=.22;mat.opacity=.95;}
      if(id==='bloodmoon'){speed=.65;size=.18;mat.opacity=.64;}
      mat.size=size;

      const attr=weatherGeo.attributes.position;
      for(let i=0;i<attr.count;i++) {
        let x=attr.getX(i), y=attr.getY(i), z=attr.getZ(i);
        if(id==='starfall') { x-=dt*speed; y-=dt*speed*.55; }
        else {
          y-=dt*speed;
          x+=Math.sin(t*1.5+i)*dt*(id==='sakura'?.42:.12);
          z+=Math.cos(t+i*.2)*dt*(id==='sakura'?.18:.025);
        }
        if(y<0 || (id==='starfall'&&x<-12)) {
          x=id==='starfall'?9+Math.random()*6:Math.random()*24-12;
          y=9+Math.random()*5;
          z=Math.random()*22-14;
        }
        attr.setXYZ(i,x,y,z);
      }
      attr.needsUpdate=true;

      if(id==='storm' && Math.random()<dt*.13) {
        lightning.intensity=5+Math.random()*5;
        setTimeout(()=>{if(lightning)lightning.intensity=0;},75+Math.random()*90);
      }
      if(weatherMoon.visible) weatherMoon.material.color.setHSL(.98,.75,.48+Math.sin(t*1.2)*.04);
    }

    function cakePrice() {
      let price=12+state.shopLevel*3+state.realm*7;
      if(state.weather===5) price+=8;
      if(state.weather===3) price+=4;
      return price;
    }

    function bake() {
      if(baking) return notify('Bánh đang được chiên!');
      if(state.money<10) return notify('Cần 10 xu để làm bánh.');
      state.money-=10;
      baking=true;
      bakeProgress=0;
      $('bakeStatus').textContent='Đang chiên…';
      sound(240,.25,'sawtooth');
      updateHUD();
      save();
    }

    function finishBake() {
      baking=false;
      $('bakeStatus').textContent='Hoàn tất!';
      const perfect=state.weather===3 || Math.random()<.25;
      state.cakes+=perfect?2:1;
      state.money+=perfect?8:0;
      state.bestScore=Math.max(state.bestScore,perfect?100:75);
      sound(perfect?880:520,.18);
      notify(perfect?'✨ Bánh Perfect! +2 bánh, +8 xu':'🍌 Bánh đã chín!');
      updateHUD();save();
    }

    function diamondBurst() {
      for(let i=0;i<18;i++) {
        const gem=new THREE.Mesh(new THREE.OctahedronGeometry(.12),
          new THREE.MeshStandardMaterial({color:0x72f7ff,emissive:0x0ea5e9,emissiveIntensity:1}));
        gem.position.set((Math.random()-.5)*2,1+Math.random()*2,1+Math.random()*2);
        scene.add(gem);
        const start=performance.now();
        const tick=now=>{
          const p=Math.min(1,(now-start)/900);
          gem.position.y+=.018;
          gem.rotation.x+=.1;
          if(p<1) requestAnimationFrame(tick);
          else scene.remove(gem);
        };
        requestAnimationFrame(tick);
      }
    }

    function sell() {
      if(state.cakes<1) return notify('Chưa có bánh để bán!');
      state.cakes--;
      let price=cakePrice();
      const mj=customers.find(c=>c.type.special);
      if(mj) {
        price*=5;
        state.gems+=1;
        notify('🕺 MJ mua bánh! Thưởng x5 và nhận ngọc!');
        diamondBurst();
        mj.state='leave';
      } else {
        notify('🛎️ Bán bánh thành công: +'+price+' xu!');
      }
      state.money+=price;
      state.served++;
      sound(1000,.16);
      updateHUD();save();
      const nearest=customers.find(c=>c.state==='wait');
      if(nearest) nearest.state='leave';
    }

    function changeWeather() {
      state.weather=(state.weather+1)%WEATHER.length;
      applyWeather();
      updateHUD();
      sound(500,.14);
      notify(WEATHER[state.weather].name+' · '+WEATHER[state.weather].desc);
      save();
    }

    function randomEvent() {
      const choices=['🌟 Golden Rush Hour','💥 Mana Burst','🕺 Michael Jackson Concert','👹 Thần Ma Đòi Bánh'];
      activeEvent=choices[Math.floor(Math.random()*choices.length)];
      eventTimer=18;
      $('eventName').textContent='Sự kiện: '+activeEvent;
      notify('🎉 Sự kiện: '+activeEvent);

      if(activeEvent.includes('Golden')) {
        state.money+=20;
        for(let i=0;i<3;i++) addCustomer();
      } else if(activeEvent.includes('Mana')) {
        state.cakes+=2;state.gems+=1;
      } else if(activeEvent.includes('Michael')) {
        addCustomer(CUSTOMER_TYPES[3]);state.gems+=2;diamondBurst();
      } else {
        addCustomer(CUSTOMER_TYPES[2]);
      }
      updateHUD();save();
    }

    function cultivate() {
      state.cultivation=Math.min(100,state.cultivation+20);
      sound(720,.12);
      if(state.cultivation>=100) notify('⚡ Tu vi đã đầy! Có thể đột phá.');
      else notify('✨ Tu luyện thành công!');
      updateHUD();save();
    }

    function breakthrough() {
      if(state.cultivation<100) return notify('Cần đủ 100 tu vi để đột phá.');
      if(state.realm>=REALMS.length-1) return notify('Đã đạt cảnh giới tối cao!');
      const cost=(state.realm+1)*100;
      if(state.money<cost) return notify('Đột phá cần '+cost+' xu.');
      state.money-=cost;state.realm++;state.cultivation=0;state.gems++;
      sound(330,.5,'triangle');
      notify('⚡ Đột phá thành công: '+REALMS[state.realm]+'!');
      updateHUD();save();
    }

    function upgrade() {
      const cost=100*state.shopLevel;
      if(state.money<cost) return notify('Cần '+cost+' xu để nâng tiệm.');
      state.money-=cost;state.shopLevel++;
      notify('🏪 Tiệm đã lên cấp '+state.shopLevel+'!');
      sound(950,.18);
      updateHUD();save();
    }

    function changeAura() {
      auraIndex=(auraIndex+1)%AURAS.length;
      state.aura=auraIndex;
      notify('Aura: '+AURAS[auraIndex].name);
      sound(600,.16);
      save();
    }

    function animate() {
      requestAnimationFrame(animate);
      const dt=Math.min(clock.getDelta(),.05);
      gameClock+=dt;
      const t=gameClock;

      if(poyo) {
        poyo.position.y=.04+Math.abs(Math.sin(t*2.4))*.1;
        const squash=Math.sin(t*2.4)*.045;
        poyo.scale.set(1+squash,1-squash,1+squash);
        poyo.rotation.y=Math.sin(t*.7)*.12;
        poyo.children.slice(2).forEach(o=>{
          if(o.geometry && o.geometry.type==='TorusGeometry') o.rotation.z+=dt*.7;
        });
      }

      customers.forEach((c,i)=>{
        const p=c.mesh.position;
        c.mesh.position.y=.02+Math.sin(t*2+c.phase)*.035;
        if(c.state==='arrive') {
          p.z+=dt*1.05;
          p.x+=(i%2===0?-1.35:1.35-p.x)*dt*.12;
          if(p.z>-1.2) { c.state='wait';c.wait=0; }
        } else if(c.state==='wait') {
          c.wait+=dt;
          if(c.type.special) {
            p.x+=Math.sin(t*2+c.phase)*dt*.35;
            c.mesh.rotation.y=Math.PI+Math.sin(t*2)*.18;
          }
          if(c.wait>28) c.state='leave';
        } else {
          p.z-=dt*1.7;
          if(p.z<-9) {
            scene.remove(c.mesh);
            customers=customers.filter(x=>x!==c);
          }
        }
      });

      spawnClock+=dt;
      if(spawnClock>7 && customers.length<4) {
        spawnClock=0;
        addCustomer();
      }

      if(baking) {
        bakeProgress=Math.min(100,bakeProgress+dt*34);
        $('bakeMeter').style.width=bakeProgress+'%';
        if(bakeProgress>=100) finishBake();
      }

      if(!activeEvent && Math.random()<dt*.012) randomEvent();
      if(activeEvent) {
        eventTimer-=dt;
        if(eventTimer<=0) {
          activeEvent='';
          $('eventName').textContent='Sự kiện: Chưa bắt đầu';
        }
      }

      updateWeather(dt,t);
      updateAura(t);
      if(controls) controls.update();
      renderer.render(scene,camera);
    }

    function resize() {
      if(!camera||!renderer)return;
      camera.aspect=innerWidth/innerHeight;
      camera.updateProjectionMatrix();
      renderer.setSize(innerWidth,innerHeight);
      renderer.setPixelRatio(Math.min(devicePixelRatio||1,2));
    }

    function takePhoto() {
      try {
        renderer.render(scene,camera);
        const link=document.createElement('a');
        link.download='poinhoinhoi-360.png';
        link.href=renderer.domElement.toDataURL('image/png');
        link.click();
        notify('📸 Đã lưu ảnh tiệm bánh!');
      } catch(e) { notify('Không thể chụp ảnh trên trình duyệt này.'); }
    }

    $('bakeButton').addEventListener('click',bake);
    $('sellButton').addEventListener('click',sell);
    $('weatherButton').addEventListener('click',changeWeather);
    $('cultivateButton').addEventListener('click',cultivate);
    $('upgradeButton').addEventListener('click',upgrade);
    $('auraButton').addEventListener('click',changeAura);
    $('photoButton').addEventListener('click',takePhoto);
    $('imageButton').addEventListener('click',()=>$('imageInput').click());
    $('imageInput').addEventListener('change',e=>{
      const file=e.target.files&&e.target.files[0];
      if(file) setImage(file);
      e.target.value='';
    });
    $('soundButton').addEventListener('click',()=>{
      state.sound=!state.sound;
      $('soundButton').textContent=state.sound?'🔊':'🔇';
      if(state.sound)sound(700,.1);
      save();
    });

    try {
      const savedImage=localStorage.getItem(IMAGE_KEY);
      if(savedImage) {
        const image=new Image();
        image.onload=()=>{
          imageSource=image;
          customers.forEach(attachReferenceImage);
        };
        image.src=savedImage;
      }
    } catch(e) {}

    try {
      init3D();
      $('soundButton').textContent=state.sound?'🔊':'🔇';
      notify('🐰 Chào mừng đến Tiệm Bánh Poinhoinhoi!');
    } catch(error) {
      console.error(error);
      $('canvas-container').innerHTML=
        '<div style="padding:24px;color:#fecdd3">Không khởi tạo được 3D. Hãy thử trình duyệt khác hoặc bật WebGL.</div>';
    }

    window.addEventListener('beforeunload',save);
  })();
  </script>
</body>
</html>
