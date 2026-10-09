using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    private Rigidbody rb;
    private float movementX;
    public float speed = 200f;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    void OnMove(InputValue movementValue)
    {
        Vector2 movementVector = movementValue.Get<Vector2>();
        movementX = movementVector.x;
    }

    void FixedUpdate()
    {
        Vector3 movement = new Vector3(movementX, 0.0f, 0.0f);
        rb.AddForce(movement * speed);

        Vector3 pos = rb.position;
        pos.x = Mathf.Clamp(pos.x, -9f, 9f);

        rb.linearVelocity = new Vector3( Mathf.Clamp(rb.linearVelocity.x, -10f, 10f), 0, 0 );
    }

    void LateUpdate()
    {
        Vector3 pos = rb.position;
        pos.x = Mathf.Clamp(pos.x, -9f, 9f);
        rb.position = pos;
    }
}