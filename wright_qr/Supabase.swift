//
//  Supabase.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 13/02/25.
//

import Foundation
import Supabase

let client = SupabaseClient(
    supabaseURL: URL(string: "https://jixksjcihngbgflmttgx.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppeGtzamNpaG5nYmdmbG10dGd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk0MDAwMTQsImV4cCI6MjA1NDk3NjAxNH0.qESjdMf89OJKLKYlPs__u4kzfMJBjX53m4evCQhA4Rk")
