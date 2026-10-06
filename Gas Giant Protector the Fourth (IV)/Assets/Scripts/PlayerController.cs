using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    // Rigidbody of the player.
    private Rigidbody rb;

    private float movementX;


    public float speed = 0;


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

    }
}