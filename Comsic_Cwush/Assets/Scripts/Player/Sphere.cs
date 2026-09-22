using UnityEngine;
using UnityEngine.InputSystem;

public class Sphere : MonoBehaviour
{
    public Transform Camera;
    public float Speed = 5.0f;

    protected Rigidbody rb;
    protected Vector2 movementVector;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
        if (Camera == null)
            Camera = UnityEngine.Camera.main.transform;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        Vector3 right = new Vector3(Camera.right.x, 0, Camera.right.z).normalized;
        Vector3 forward = new Vector3(Camera.forward.x, 0, Camera.forward.z).normalized;
        rb.AddForce(((right * movementVector.x) + (forward * movementVector.y)) * Speed);

        //if (rb.linearVelocity.magnitude > 0.1)
        //    transform.LookAt(transform.position + new Vector3(rb.linearVelocity.x, 0, rb.linearVelocity.z), Vector3.up);
    }

    void OnMove(InputValue movementValue)
    {
        movementVector = movementValue.Get<Vector2>();
    }
}
