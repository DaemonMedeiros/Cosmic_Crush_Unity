using UnityEngine;

public class BulletManager : MonoBehaviour
{

    public GameObject bulletPrefab;
    public GameObject player;

    private Rigidbody playerRb;
    private InputSystem_Actions controls;


    void Start()
    {
        controls = new InputSystem_Actions();
        controls.Player.Enable();
        playerRb = player.GetComponent<Rigidbody>();
    }

    void Update()
    {
        if(controls.Player.Jump.WasPressedThisFrame())
        {
            Vector3 playerPos = new Vector3(playerRb.position.x, playerRb.position.y, -7.65f);
            Instantiate(bulletPrefab, playerPos, Quaternion.Euler(-90.0f, 0.0f, 0.0f));
        }
    }
}
