<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>TESTNET-IBC Validator Docs</title>
  <style>
    body {
      font-family: "Segoe UI", sans-serif;
      line-height: 1.7;
      padding: 20px;
      max-width: 900px;
      margin: auto;
      transition: 0.3s;
      background-color: #ffffff;
      color: #000000;
    }
    .dark-mode {
      background-color: #121212;
      color: #e0e0e0;
    }
    .toggle-mode {
      position: fixed;
      top: 15px;
      right: 20px;
      background: #444;
      color: #fff;
      border: none;
      padding: 8px 12px;
      border-radius: 8px;
      cursor: pointer;
      font-size: 14px;
    }
    a { color: #1e88e5; text-decoration: none; }
    .dark-mode a { color: #90caf9; }

    h1, h2, h3 { margin-top: 1.5em; }
    .validator-grid {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 16px;
      margin-top: 20px;
    }
    .validator-card {
      border: 1px solid #ccc;
      border-radius: 12px;
      padding: 10px;
      width: 90px;
      text-align: center;
      background: #f9f9f9;
    }
    .dark-mode .validator-card {
      border-color: #444;
      background: #1e1e1e;
    }
    .validator-card img {
      width: 60px;
      border-radius: 50%;
    }
    .validator-card span {
      display: block;
      margin-top: 8px;
      font-size: 12px;
    }
    hr {
      border: none;
      border-top: 1px solid #ddd;
    }
    .dark-mode hr {
      border-color: #444;
    }
  </style>
</head>
<body>
  <button class="toggle-mode" onclick="toggleMode()">🌓 Dark/Light</button>

  <h1>🚀 TESTNET-IBC Validator Docs</h1>
  <p>Welcome to the <strong>TESTNET-IBC</strong> directory! This folder serves as a dedicated space for everything related to Inter-Blockchain Communication (IBC) testnets. Here, you will find important resources, setup guides, and configurations for various testnets utilizing the IBC protocol.</p>

  <h2>📘 What You’ll Find Here</h2>
  <ul>
    <li><strong>Network Setup Instructions</strong> – Step-by-step guides for connecting to IBC-enabled testnets.</li>
    <li><strong>Configuration Files</strong> – Essential configurations for seamless interoperability.</li>
    <li><strong>Validators & Nodes</strong> – Guidelines for running a validator or full node on IBC testnets.</li>
    <li><strong>Updates & Announcements</strong> – Stay informed about the latest developments and upgrades.</li>
  </ul>

  <h2>💡 About IBC</h2>
  <p>The <strong>Inter-Blockchain Communication (IBC)</strong> protocol enables seamless communication between different blockchain networks, allowing for secure and decentralized cross-chain transactions. This directory aims to support the growth and adoption of IBC by providing structured and accessible information.</p>

  <blockquote>📌 Stay tuned for more updates and feel free to contribute to enhance the resources in this directory! 🚀</blockquote>

  <h3 align="center">🟢 Active Validators</h3>

  <div class="validator-grid">
    <a href="https://github.com/OneNov0209/testnet-ibc/tree/main/Ogchain" class="validator-card">
      <img src="https://pbs.twimg.com/profile_images/1933474287027171329/L-I1k2oL.jpg" alt="Ogchain">
      <span>Ogchain</span>
    </a>

    <a href="https://github.com/OneNov0209/testnet-ibc/tree/main/Symphony" class="validator-card">
      <img src="https://pbs.twimg.com/profile_images/1896255605909725184/rC9pD5EQ.jpg" alt="Symphony">
      <span>Symphony</span>
    </a>

    <a href="https://github.com/OneNov0209/testnet-ibc/tree/main/Kiichain" class="validator-card">
      <img src="https://pbs.twimg.com/profile_images/1800553180083666944/zZe128CW.jpg)" alt="Kiichain">
      <span>Kiichain</span>
    </a>

    <a href="https://github.com/OneNov0209/testnet-ibc/tree/main/Empeirias" class="validator-card">
      <img src="https://pbs.twimg.com/profile_images/1887069794798632960/IvxbLJcg.jpg" alt="Empeirias">
      <span>Empeiria</span>
    </a>

    <a href="https://github.com/OneNov0209/testnet-ibc/tree/main/XOS" class="validator-card">
      <img src="https://pbs.twimg.com/profile_images/1861059503325913088/axi4e4i1.jpg" alt="XOS">
      <span>XOS</span>
    </a>

    <a href="https://github.com/OneNov0209/testnet-ibc/tree/main/BlockX-Mainnet" class="validator-card">
      <img src="https://pbs.twimg.com/profile_images/1571914336288776193/HmxJDHvF.jpg" alt="BlockX">
      <span>BlockX</span>
    </a>
  </div>

  <script>
    function toggleMode() {
      document.body.classList.toggle('dark-mode');
    }
  </script>
</body>
</html>
