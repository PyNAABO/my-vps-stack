import bcrypt
import os

password = b"adminadmin1234"
hashed = bcrypt.hashpw(password, bcrypt.gensalt(rounds=10)).decode("utf-8")

config_dir = "config/dozzle"
if not os.path.exists(config_dir):
    os.makedirs(config_dir)

yaml_content = f"""users:
  - username: admin
    password: {hashed}
    name: Admin User
    email: admin@example.com
"""

with open(f"{config_dir}/users.yml", "w", encoding="utf-8") as f:
    f.write(yaml_content)

print(f"✅ Generated {config_dir}/users.yml with new hash for 'adminadmin1234'")
