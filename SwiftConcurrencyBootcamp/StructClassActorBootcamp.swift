//
//  StructClassActorBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Juan David Gutierrez Olarte on 6/09/25.
//


/*
 
 VALUE TYPES:
 - Struct, Enum, String, Int, etc.
 - Stored in Stack
 - Faster
 - Thread safe by default!
 - When you assign or pass value type a new copy of data is created.
 
 REFERENCE TYPES:
 - Class, Function, Actor
 - Stored in the Heap
 - Slower, but synchronized
 - NOT Thread Safe by Default
 - When you assign or pass reference type a new reference to original instance will be created (pointer)
 
 ----------------------------------------------
 
 STACK:
 - Stores Values types
 - Variables allocated on the stack are stored directly to the memory, and access to this memory is very fast
 - Each thread has its own stack!
 
 HEAP:
 - Stores Reference types
 - Shared across threads!
 -
 ----------------------------------------------
 
 STRUCT:
 - Based on VALUES
 - Can be mutated
 - Stored in the Stack!
 
 CLASS:
 - Based on REFERENCES (INSTANCES)
 - Cannot be mutated, instead we change the values inside there.
 - Stored in the HEAP!
 - Can inherit from other classes
 
 ACTOR:
 - Same as Class, but thread safe!
 
 ----------------------------------------------
 
 When to use normally:
 
 Structs: Data Models (IMMUTABLE specially), Views
 Classes: ViewModels for views
 Actors: Shared 'Manager' and 'Data Store' classes
 
 
 
 */


import SwiftUI

actor StructClassActorBootcampDataManager {
    
}

class StructClassActorBootcampViewModel: ObservableObject {
    
    @Published var title: String = ""
    
    init(){
        print("ViewModel INIT")
    }
    
}

struct StructClassActorBootcamp: View {
    
    @StateObject private var viewModel = StructClassActorBootcampViewModel()
    let isActive: Bool
    
    init(isActive: Bool) {
        self.isActive = isActive
        print("View INIT")
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(isActive ? Color.red : Color.blue)
            .onAppear {
//                runText()
            }
    }
}

struct StructClassActorBootcampHomeView: View {
    
    @State private var isActive: Bool = false
    
    var body: some View {
        StructClassActorBootcamp(isActive: isActive)
            .onTapGesture {
                isActive.toggle()
            }
    }
}


#Preview {
    StructClassActorBootcamp(isActive: true)
}





extension StructClassActorBootcamp {
    private func runText() {
        print("Text started")
        structTest1()
        printDivider()
                classTest1()
        printDivider()
        actorTest1()
//        structTest2()
//        printDivider()
//        classTest2()
    }
    
    private func printDivider() {
        print("""
            
            ---------------------------
            
            """)
    }
    
    private func structTest1() {
        print("Struct Test 1")
        let objectA = MyStruct(title: "Starting Title!")
        print("ObjectA: ", objectA.title)
        
        print("Pass the VALUES of objectA to objectB")
        var objectB = objectA
        print("ObjectB: ", objectB.title)
        
        objectB.title = "Second title!"
        print("ObjectB title changed")
        
        print("ObjectA: ", objectA.title)
        print("ObjectB: ", objectB.title)
    }
    
    private func classTest1() {
        print("Class Test 1")

        let objectA = MyClass(title: "Starting Title")
        print("ObjectA: ", objectA.title)
        
        print("Pass the REFERENCE of objectA to objectB")
        let objectB = objectA
        print("ObjectB: ", objectB.title)
        
        objectB.title = "Second title!"
        print("ObjectB title changed")
        
        print("ObjectA: ", objectA.title)
        print("ObjectB: ", objectB.title)
        
    }
    
    private func actorTest1()  {
        Task {
            print("Actor Test 1")

            let objectA = MyActor(title: "Starting Title")
            await print("ObjectA: ", objectA.title)
            
            print("Pass the REFERENCE of objectA to objectB")
            let objectB = objectA
            await print("ObjectB: ", objectB.title)
            
            await objectB.updateTitle(newTitle: "Second Title!")
            print("ObjectB title changed")
            
            await print("ObjectA: ", objectA.title)
            await print("ObjectB: ", objectB.title)
        }
       
        
    }
    
    
}

struct MyStruct {
    var title: String
}

// IMMUTABLE struct
struct CustomStruct {
    let title: String
    
    func updateTitle(newTitle: String) -> CustomStruct{
        CustomStruct(title: newTitle)
    }
    
}

struct MutatingStruct {
    // We make the variables private for protection and only to update the object from the function.
    private(set) var title: String
    
    
    // requires init
    init(title: String) {
        self.title = title
    }
    
    //we're changing the entire object, not just the title. Totally new struct with new values
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActorBootcamp {
    
    private func structTest2() {
        print("structTest2")
        
        var struct1 = MyStruct(title: "Title1")
        print("Struct1: ", struct1.title )
        struct1.title = "Title2"
        print("Struct1: ", struct1.title)
        
        var struct2 = CustomStruct(title: "Title1")
        print("Struct2: ", struct2.title )
        struct2 = CustomStruct(title: "Title2")
        print("Struct2: ", struct2.title )
        
        var struct3 = CustomStruct(title: "Title1")
        print("Struct3: ", struct3.title )
        struct3 = struct3.updateTitle(newTitle: "Title2")
        print("Struct3: ", struct3.title )
        
        var struct4 = MutatingStruct(title: "Title1")
        print("Struct4: ", struct4.title )
        struct4.updateTitle(newTitle: "Title2")
        print("Struct4: ", struct4.title )
        
        
    }
    
}

class MyClass {
    var title: String
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

actor MyActor {
    var title: String
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}


extension StructClassActorBootcamp {
    
    private func classTest2() {
        print("classTest2")
        
        let class1 = MyClass(title: "Title1")
        print("Class1: ", class1.title)
        class1.title = "Title2"
        print("Class1: ", class1.title)
        
        let class2 = MyClass(title: "Title1")
        print("Class2: ", class2.title)
        class2.updateTitle(newTitle: "Title2")
        print("Class2: ", class2.title)
    }
    
}
